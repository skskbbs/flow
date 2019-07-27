//
//  TBBaseNetwork.m
//  SaasApp
//
//  Created by ToothBond on 15/11/4.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "TBBaseNetwork.h"
#import "UIKit+AFNetworking.h"
#import "TBNetworkConfig.h"
#import "MJExtension.h"
#import "TBResponse.h"
#import "TBCacheTool.h"
#import "AFHTTPSessionManagerClient.h"


NSString *const NetworkingReachableViaWWANNotification = @"NetworkingReachableViaWWAN";
NSString *const NetworkingReachableViaWIFINotification = @"NetworkingReachableViaWIFI";
NSString *const NetworkingNotReachableNotification     = @"NetworkingNotReachable";

static BOOL _canSendMessage = YES;

@interface TBBaseNetwork()

@property(nonatomic,strong)AFHTTPSessionManagerClient *manager;
@property(nonatomic,strong)NSURLSessionDataTask *httpOperation;
@property(nonatomic)    TBCancelType cancelType;


/**
 *  默认设置
 */
-(void)defaultConfig;

/**
 *  初始化网络状态监测
 */
+ (void)networkReachability;
@end

@implementation TBBaseNetwork

#pragma mark - 网络状态监控
+(void)initialize {
    if (self == [TBBaseNetwork class]) {
        [self showNetworkActivityIndicator:YES];
        [self networkReachability];
        [self startMonitoring];
    }
}

+(void)showNetworkActivityIndicator:(BOOL)isShow {
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:isShow];
}

+(void)networkReachability {
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
                if (_canSendMessage == YES) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingReachableViaWWANNotification
                                                                        object:nil
                                                                      userInfo:nil];
                }
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                if (_canSendMessage == YES) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingReachableViaWIFINotification
                                                                        object:nil
                                                                      userInfo:nil];
                }
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                if (_canSendMessage == YES) {
                    [[NSNotificationCenter defaultCenter] postNotificationName:NetworkingNotReachableNotification
                                                                        object:nil
                                                                      userInfo:nil];
                }
                break;
        }
    }];
}

+(void)startMonitoring {
    _canSendMessage = YES;
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

+(void)stopMonitoring {
    _canSendMessage = NO;
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

+(BOOL)isReachable {
    return [AFNetworkReachabilityManager sharedManager].isReachable;
}

+ (BOOL)isReachableViaWWAN {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWWAN;
}

+ (BOOL)isReachableViaWIFI {
    return [AFNetworkReachabilityManager sharedManager].isReachableViaWiFi;
}

#pragma  mark - 初始化
-(instancetype) init {
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

-(void)defaultConfig {
    self.manager = [AFHTTPSessionManagerClient sharedClient];
    self.isRunning = NO;
    self.repeatRequestOpeationType = AFNetworkRepeatRequestOpeationRefresh;
}

-(void)dealloc {
    self.isRunning = NO;
    self.cancelType = TBCancelTypeDealloc;
    [self.httpOperation cancel];
    self.httpOperation = nil;
    self.manager = nil;
    DEBUG_NSLOG(@"dealloc : ------%@------",self.urlString);
}

#pragma mark - 扩展
- (void)setupRequestHeader
{
//    NSMutableDictionary *header = [NSMutableDictionary dictionary];
//    TBUserData *data = [TBUserManager sharedInstance].userData;
//    if (data.token) {
//        [header setObject:data.token forKey:@"wms-token"];
//    }
//    NSString *hospId = data.hospId;
//    if (data.hospId) {
//        [header setObject:hospId forKey:@"hospId"];
//    }
//    if (self.HTTPHeaderFieldsWithValues) {
//        [self.HTTPHeaderFieldsWithValues addEntriesFromDictionary:header];
//    }else{
//        self.HTTPHeaderFieldsWithValues = [header mutableCopy];
//    }
//
//    NSObject * dictHospId = [self.requestDictionary objectForKey:@"hospId"];
//    if(dictHospId == nil  && hospId){
//        NSMutableDictionary * formDict = [NSMutableDictionary dictionaryWithDictionary:self.requestDictionary];
//        [formDict setObject:hospId forKey:@"hospId"];
//        self.requestDictionary = [formDict mutableCopy];
//    }
}

#pragma mark 构造方法
+(instancetype)networkingWithUrlString:(NSString *)urlString
                     requestDictionary:(NSDictionary *)requestDictionary
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                       timeoutInterval:(NSNumber *)timeoutInterval
                                  flag:(NSInteger )flag
                         requestMethod:(AFNetworkRequestMethod)requestMethod
                  urlRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer
                 urlResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer
{
    TBBaseNetwork *aiyaApi     = [[TBBaseNetwork alloc]init];
    if ([urlString rangeOfString:@"http"].location == NSNotFound) {
        aiyaApi.urlString          = [NSString stringWithFormat:@"%@/%@",TBBaseURL,urlString];
    }else{
        aiyaApi.urlString          = urlString;
    }
    
    aiyaApi.requestDictionary  = requestDictionary;
    aiyaApi.timeoutInterval    = timeoutInterval;
    aiyaApi.flag               = flag;
    aiyaApi.delegate           = delegate;
    aiyaApi.requestMethod      = requestMethod;
    if (requestSerializer) {
        aiyaApi.requestSerializer  = requestSerializer;
    }else{
        aiyaApi.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    
    aiyaApi.responseSerializer = responseSerializer;
    
    aiyaApi.requestDictionarySerializer = [[RequestDictionarySerializer alloc] init];
    NSDictionary *header = @{@"Content-Type":@"application/x-www-form-urlencoded; charset=utf-8"};
    aiyaApi.HTTPHeaderFieldsWithValues = [header mutableCopy];
    return aiyaApi;
}

+(instancetype)networkingWithUrlString:(NSString *)urlString
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                         requestMethod:(AFNetworkRequestMethod)requestMethod {
    return [[self class] networkingWithUrlString:urlString
                               requestDictionary:nil
                                        delegate:delegate
                                 timeoutInterval:nil
                                            flag:0
                                   requestMethod:requestMethod
                            urlRequestSerializer:nil
                           urlResponseSerializer:nil];
}
+(instancetype)networkingWithUrlString:(NSString *)urlString
                     requestDictionary:(NSDictionary *)requestDictionary
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                         requestMethod:(AFNetworkRequestMethod)requestMethod
{
    return [[self class] networkingWithUrlString:urlString
                               requestDictionary:requestDictionary
                                        delegate:delegate
                                 timeoutInterval:nil
                                            flag:0
                                   requestMethod:requestMethod
                            urlRequestSerializer:nil
                           urlResponseSerializer:nil];
}

+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                                  delegate:(id<TBBaseNetworkProrocol>)delegate
                             requestMethod:(AFNetworkRequestMethod)requestMethod
{
    TBBaseNetwork *network =  [[self class] networkingWithUrlString:urlString
                               requestDictionary:nil
                                        delegate:delegate
                                 timeoutInterval:nil
                                            flag:0
                                   requestMethod:requestMethod
                            urlRequestSerializer:nil
                           urlResponseSerializer:nil];
    RequestDictionarySerializer *serializer = [[TokenRequestSerializer alloc] init];
    network.requestDictionarySerializer = serializer;
    return network;
}

+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                             requestMethod:(AFNetworkRequestMethod)requestMethod
{
    TBBaseNetwork *network =  [[self class] networkingWithUrlString:urlString
                                                  requestDictionary:nil
                                                           delegate:nil
                                                    timeoutInterval:nil
                                                               flag:0
                                                      requestMethod:requestMethod
                                               urlRequestSerializer:nil
                                              urlResponseSerializer:nil];
    RequestDictionarySerializer *serializer = [[TokenRequestSerializer alloc] init];
    network.requestDictionarySerializer = serializer;
    
    return network;
}

#pragma mark - 请求网络
-(void)startRequest:(TBFetchDataPolicy)policy
{
    if (self.urlString.length <= 0) {
        return;
    }
    if (_isRunning) {
        if (self.repeatRequestOpeationType == AFNetworkRepeatRequestOpeationRefresh) {
            DEBUG_NSLOG(@"refresh request : %@",self.urlString);
            [self cancelRequest];
        }else if(self.repeatRequestOpeationType == AFNetworkRepeatRequestOpeationProtect){
            DEBUG_NSLOG(@"cancel request : %@",self.urlString);
            return;
        }
    }
    
    _isRunning = YES;
    
    //请求类型
    if (self.requestSerializer) {
        self.manager.requestSerializer = self.requestSerializer;
    }else{
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    }
    //响应类型
    if (self.responseSerializer) {
        self.manager.responseSerializer = self.responseSerializer;
    }else{
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    //设置请求头
    [self setupRequestHeader];
    if (self.HTTPHeaderFieldsWithValues) {
        NSArray *allKeys = self.HTTPHeaderFieldsWithValues.allKeys;
        for (NSString *headerField in allKeys) {
            NSString *value = [self.HTTPHeaderFieldsWithValues valueForKey:headerField];
            [self.manager.requestSerializer setValue:value forHTTPHeaderField:headerField];//modify by wj
        }
    }
    DEBUG_NSLOG(@"url:%@\n请求头:%@",self.urlString,self.manager.requestSerializer.HTTPRequestHeaders);
    //设置超时时间
    if (self.timeoutInterval && self.timeoutInterval.floatValue > 0) {
        [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.manager.requestSerializer.timeoutInterval = self.timeoutInterval.floatValue;
        [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    
    //设置请求参数转换器
    if (self.requestDictionarySerializer == nil) {
        self.requestDictionarySerializer = [[RequestDictionarySerializer alloc] init];
    }
    //设置响应参数转换器
    if (self.responseDataSerializer == nil) {
        self.responseDataSerializer = [[ResponseDataSerializer alloc] init];
    }
    
    __weak TBBaseNetwork *weakSelf = self;
    //处理入参 block内部中引用外部变量
    __block NSDictionary *requestDict = [self.requestDictionarySerializer transformRequestDictionaryWithInputDictionary:self.requestDictionary];
    //检查token
    if (requestDict == nil) {
        DEBUG_NSLOG(@"================ token auth failure =======");
        TBResponse *response = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeTokenFailure
                                                                 dataTask:nil
                                                                     flag:0
                                                             responseData:nil];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestFailed:)]) {
            [weakSelf.delegate requestFailed:response];
        }
        self.isRunning = NO;
        return;
    }
    
    //读取缓存
    if (policy != TBFetchDataPolicyIgnoreCache && (self.cacheType == TBCacheTypeOnlyMemoryCache || self.cacheType == TBCacheTypeFullCache)) {
        id cacheResponseObject = nil;
        if (self.cacheType == TBCacheTypeOnlyMemoryCache) {
            cacheResponseObject = [TBCacheTool fetchMemoryCacheDataWithUrl:self.urlString requestParams:requestDict];
        }
        else if(self.cacheType == TBCacheTypeFullCache){
            cacheResponseObject = [TBCacheTool fetchCacheDataWithUrl:self.urlString requestParams:requestDict];
        }
        if (cacheResponseObject != nil) {
            //            DEBUG_NSLOG(@"\n\nurl:%@\n\n>>>>>>>>>>>>>>>>>>>>>           cache data:\n%@\n\n<<<<<<<<<<<<<<<<<<<<<<\n\n",weakSelf.urlString,[StringUtils stringFromData:cacheResponseObject]);
            
            NSError *cacheError = nil;
            id responseData = [weakSelf.responseDataSerializer transformResponseDataWithInputData:cacheResponseObject error:&cacheError];
            if (cacheError == nil && responseData) {
                TBURLSuccessCode successCode = [responseData[@"code"] integerValue];
                TBResponse *successResponse = [[TBResponse alloc] initWithResponseStatus:successCode
                                                                                dataTask:weakSelf.httpOperation
                                                                                    flag:weakSelf.flag
                                                                            responseData:responseData];
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestSuccess:)]) {
                    [weakSelf.delegate requestSuccess:successResponse];
                }
                //只加载内存中的数据
                if (policy == TBFetchDataPolicyUseCache) {
                    self.isRunning = NO;
                    return;
                }
            }
        }
    }
    
    if (self.requestMethod == GET_METHOD) {
        DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>>>>    network Request   start\n\nurl : %@%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    network Request   end\n\n",self.urlString,[StringUtils dictToGetParams:requestDict]);
        
        self.httpOperation = [self.manager GET:self.urlString
                                    parameters:requestDict
                                      progress:nil
                                       success:^(NSURLSessionDataTask * task, id responseObject) {
                                           [weakSelf handleSuccessRequest:requestDict task:task resp:responseObject];
                                       }
                                       failure:^(NSURLSessionDataTask * task, NSError * error) {
                                           [weakSelf handleFailureRequest:requestDict task:task error:error];
                                           
                                       }];
    }else if(self.requestMethod == POST_METHOD){
        DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>>>>    network Request   start\n\nurl : %@\nPOST Params: \n%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    network Request   end\n\n",self.urlString,[requestDict mj_JSONString]);
        
        if (_isRequestWithFormData) {
            
            self.httpOperation  = [self.manager POST:self.urlString parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
                
                for (NSString *key in self.requestDictionary) {
                    id value = [self.requestDictionary objectForKey:key];
                    NSData *data = nil;
                    if ([value isKindOfClass:[NSString class]]) {//字符串
                        NSString *str = (NSString*)value;
                        data = [str dataUsingEncoding:NSUTF8StringEncoding];
                    }
                    if ([value isKindOfClass:[NSNumber class]]) {
                        NSNumber *num = (NSNumber*)value;
                        data = [num.stringValue dataUsingEncoding:NSUTF8StringEncoding];
                    }
                    if ([value isKindOfClass:[NSArray class]]) {//数组
                        NSArray *list = (NSArray*)value;
                        data = [list mj_JSONData];
                    }
                    if (data) {
                        [formData appendPartWithFormData:data name:key];
                    }
                    
                }
                
            } progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                
                [weakSelf handleSuccessRequest:requestDict task:task resp:responseObject];
                
            } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                
                [weakSelf handleFailureRequest:requestDict task:task error:error];
                
            }];
            
        }else{
            
            self.httpOperation = [self.manager POST:self.urlString
                                         parameters:requestDict
                                           progress:nil
                                            success:^(NSURLSessionDataTask * task, id responseObject) {
                                                [weakSelf handleSuccessRequest:requestDict task:task resp:responseObject];
                                            }
                                            failure:^(NSURLSessionDataTask * task, NSError * error) {
                                                [weakSelf handleFailureRequest:requestDict task:task error:error];
                                            }];
            
        }
        
        
    }
}
-(void)startRequest
{
    [self startRequest:TBFetchDataPolicyDefault];
}

- (void)handleSuccessRequest:(id)requestDict task:(NSURLSessionDataTask *)task resp:(id)responseObject
{
    self.isRunning = NO;
    NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
#ifdef DEBUG_LOG_TAG
    DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>  response data:  url:%@\n\n%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n",self.urlString,responseString);
#endif
    id responseData = nil;
    TBURLSuccessCode successCode = TBURLSuccessCodeNoData;
    NSString *resonseMsg = @"";
    NSError *error = nil;
    responseData = [self.responseDataSerializer transformResponseDataWithInputData:responseObject error:&error];
    if (error == nil && responseData && [responseData objectForKey:@"status"]) {
        successCode = [responseData[@"status"] integerValue];
        resonseMsg = [responseData objectForKey:@"msg"];
        if([resonseMsg isKindOfClass:[NSNull class]] || resonseMsg == nil){
            resonseMsg = @"";
        }
    }else{
        TBResponse *failResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeServerError
                                                                     dataTask:self.httpOperation
                                                                         flag:self.flag
                                                                 responseData:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]) {
            [self.delegate requestFailed:failResponse];
        }
        return;
    }
    //处理401 权限变更、异地登录
    if ((successCode == TBURLSuccessCodeTokenFailure || successCode == TBURLSuccessCodeAuthFailure) && [StringUtils isNotEmptyString:[requestDict objectForKey:@"token"]]
        ) {
        
        //过滤登出接口，避免死循环
        if ([self.urlString isEqualToString:@"system/config"]) {
        }
        else{
//            if (successCode == TBURLSuccessCodeTokenFailure) { //403
//                [kTBAppDelegate showTokenErrorMsg];
//            }else if(successCode == TBURLSuccessCodeAuthFailure){
//                [kTBAppDelegate showTokenErrorMsg:@"你的账号权限已变更，请重新登录"];
//            }
            
            return;
        }
    }
    //处理901 token过期
    if (successCode == TBURLSuccessCodeTokenExpire) {
        //过滤登出接口，避免死循环
        if ([self.urlString isEqualToString:@"system/config"]) {
        }
        else{
//            [kTBAppDelegate showTokenErrorMsg:@"你的账号信息已过期，请重新登录"];
            return;
        }
    }
    
    if ([resonseMsg isEqualToString:@"用户不存在"]) {
        resonseMsg = @"用户名或密码错误";
    }
    TBResponse *successResponse = [[TBResponse alloc] initWithResponseStatus:successCode
                                                                   statusMsg:resonseMsg
                                                                    dataTask:self.httpOperation
                                                                        flag:self.flag
                                                                responseData:responseData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(requestSuccess:)]) {
        [self.delegate requestSuccess:successResponse];
    }
    //请求成功，Code＝200 才缓存
    if (successCode == TBURLSuccessCodeSuccess) {
        if (self.cacheType == TBCacheTypeOnlyMemoryCache) {
            [TBCacheTool saveMemoryCacheWithData:responseObject url:self.urlString requestParams:requestDict];
        }
        else if(self.cacheType == TBCacheTypeFullCache){
            [TBCacheTool saveCacheWithData:responseObject url:self.urlString requestParams:requestDict];
        }
    }
}

- (void)handleFailureRequest:(id)requestDict task:(NSURLSessionDataTask *)task error:(NSError *)error
{
    self.isRunning = NO;
    if (self.cancelType == TBCancelTypeUser) {
        DEBUG_NSLOG(@" >>>>>>>>>>>>   url:%@ %@ \n%@  <<<<<<<<<<<<<" ,self.urlString, @"Request Error",error.userInfo);
        TBResponse *cancelResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeNoNetwork
                                                                       dataTask:self.httpOperation
                                                                           flag:self.flag
                                                                   responseData:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestCancel:)]) {
            [self.delegate requestCancel:cancelResponse];
        }
    }else{
        DEBUG_NSLOG(@" =========================\n %@ \n%@ \n%@ \n=========================" ,
                    error.localizedDescription,
                    error.domain,
                    error.userInfo.descriptionInStringsFileFormat);
        TBResponse *failResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeServerError
                                                                     dataTask:self.httpOperation
                                                                         flag:self.flag
                                                                 responseData:nil];
        if (self.delegate && [self.delegate respondsToSelector:@selector(requestFailed:)]) {
            [self.delegate requestFailed:failResponse];
        }
    }
}

-(void)cancelRequest
{
    self.isRunning = NO;
    self.cancelType = TBCancelTypeUser;
    [self.httpOperation cancel];
}

#pragma mark - 单个文件上传
-(void)uploadFile
{
    if (self.urlString.length <= 0) {
        return;
    }
    _isRunning = YES;
    
    //请求类型
    if (self.requestSerializer) {
        self.manager.requestSerializer = self.requestSerializer;
    }else{
        self.manager.requestSerializer = [AFJSONRequestSerializer serializer];
    }
    //响应类型
    if (self.responseSerializer) {
        self.manager.responseSerializer = self.responseSerializer;
    }else{
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    }
    
    //设置请求参数转换器
    if (self.requestDictionarySerializer == nil) {
        self.requestDictionarySerializer = [[RequestDictionarySerializer alloc] init];
    }
    //设置响应参数转换器
    if (self.responseDataSerializer == nil) {
        self.responseDataSerializer = [[ResponseDataSerializer alloc] init];
    }
    
    self.manager.responseSerializer.acceptableContentTypes = [self.manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
    
    __weak TBBaseNetwork *weakSelf = self;
    //处理入参 block内部中引用外部变量
    __block NSDictionary *requestDict = [self.requestDictionarySerializer transformRequestDictionaryWithInputDictionary:self.requestDictionary];
    //检查token
    if (requestDict == nil) {
        DEBUG_NSLOG(@"================ token auth failure =======");
        TBResponse *response = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeTokenFailure
                                                                dataTask:nil
                                                                     flag:0
                                                             responseData:nil];
        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestFailed:)]) {
            [weakSelf.delegate requestFailed:response];
        }
        return;
    }
    
    [self.manager             POST:self.urlString
                        parameters:requestDict
         constructingBodyWithBlock:weakSelf.constructingBodyBlock
                          progress:weakSelf.uploadProgressBlock
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                   
                   [weakSelf handleSuccessRequest:requestDict task:task resp:responseObject];
               }
               failure:^(NSURLSessionDataTask * _Nonnull task, NSError * _Nonnull error) {
                   [weakSelf handleFailureRequest:requestDict task:task error:error];
               }];
}


#pragma mark - block

//+(NSURLSessionDataTask *)POST:(NSString *)URLString
//                   parameters:(id)parameters
//                      success:(void (^)(NSURLSessionDataTask *, TBResponse *resp))success
//                      failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
//{
//    return [self POST:URLString
//           parameters:parameters
//      timeoutInterval:nil urlRequestSerializer:nil urlResponseSerializer:nil
//              success:success
//              failure:failure];
//}
//
//+(NSURLSessionDataTask *)POST:(NSString *)URLString
//                     parameters:(id)parameters
//                timeoutInterval:(NSNumber *)timeoutIntervall
//                    urlRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer
//                   urlResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer
//                        success:(void (^)(NSURLSessionDataTask *, TBResponse *resp))success
//                        failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
//{
//    AFHTTPSessionManager *manager            = [AFHTTPSessionManager manager];
//    NSString *absolutelyUrl = @"";
//    if ([URLString rangeOfString:@"http"].location == NSNotFound) {
//        absolutelyUrl          = [NSString stringWithFormat:@"%@%@",TBBaseURL,URLString];
//    }else{
//        absolutelyUrl          = URLString;
//    }
//    //请求类型
//    if (requestSerializer) {
//        manager.requestSerializer = requestSerializer;
//    }else{
//        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
//    }
//    //响应类型
//    if (responseSerializer) {
//        manager.responseSerializer = responseSerializer;
//    }else{
//        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    }
//
//    NSDictionary *header = @{@"Content-Type":@"application/x-www-form-urlencoded; charset=utf-8"};
//    NSArray *allKeys = header.allKeys;
//    for (NSString *headerField in allKeys) {
//        NSString *value = [header valueForKey:headerField];
//        [manager.requestSerializer setValue:value forHTTPHeaderField:headerField];
//    }
//
//    // 设置回复内容信息
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//    // 设置超时时间
//    if (timeoutIntervall) {
//        [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
//        manager.requestSerializer.timeoutInterval = timeoutIntervall.floatValue;
//        [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
//    }
//
//    DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>>>>    network Request   start\n\nurl : %@\nPOST Params: \n%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    network Request   end\n\n",absolutelyUrl,[parameters JSONString]);
//    NSURLSessionDataTask *dataTask = [manager POST:absolutelyUrl
//                                               parameters:parameters
//                                                 progress:nil
//                                                  success:^(NSURLSessionDataTask *task, id responseObject) {
//                                                      NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//#ifdef DEBUG_LOG_TAG
//                                                      DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>  response data:  url:%@\n\n%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n",absolutelyUrl,responseString);
//#endif
//                                                      TBResponse *successResponse = nil;
//                                                      NSError *respError = nil;
//                                                      id responseData = [ResponseDataSerializer transformResponseDataWithInputData:responseObject error:&respError];
//                                                      if (respError == nil && responseData) {
//                                                          TBURLSuccessCode successCode = TBURLSuccessCodeSuccess;
//                                                          if ([responseData objectForKey:@"code"]) {
//                                                              successCode = [responseData[@"code"] integerValue];
//                                                          }
//                                                          NSString *resonseMsg = [responseData objectForKey:@"msg"];
//                                                          successResponse = [[TBResponse alloc] initWithResponseStatus:successCode
//                                                                                                                         statusMsg:resonseMsg
//                                                                                                                          dataTask:task
//                                                                                                                              flag:0
//                                                                                                                      responseData:responseData];
//                                                      }else{
//                                                          successResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeServerError
//                                                                                                                       dataTask:task
//                                                                                                                           flag:0
//                                                                                                                   responseData:nil];
//                                                      }
//                                                      if (success) {
//                                                          success(task, successResponse);
//                                                      }
//                                                  }
//                                                  failure:^(NSURLSessionDataTask *task, NSError *error) {
//                                                      if (failure) {
//                                                          failure(task, error);
//                                                      }
//                                                  }];
//
//
//    return dataTask;
//}
//
//+(NSURLSessionDataTask *)GET:(NSString *)URLString
//                  parameters:(id)parameters
//                     success:(void (^)(NSURLSessionDataTask *, id respData))success
//                     failure:(void (^)(NSURLSessionDataTask *, NSError *))failure
//{
//    AFHTTPSessionManager *manager            = [AFHTTPSessionManager manager];
//    NSString *absolutelyUrl = @"";
//    if ([URLString rangeOfString:@"http"].location == NSNotFound) {
//        absolutelyUrl          = [NSString stringWithFormat:@"%@%@",TBBaseURL,URLString];
//    }else{
//        absolutelyUrl          = URLString;
//    }
//    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
//    manager.responseSerializer.acceptableContentTypes = [manager.responseSerializer.acceptableContentTypes setByAddingObject:@"text/html"];
//
//    DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>>>>    network Request   start\n\nurl : %@%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<    network Request   end\n\n",absolutelyUrl,[StringUtils dictToGetParams:parameters]);
//    NSURLSessionDataTask *dataTask = [manager GET:absolutelyUrl
//                                       parameters:parameters
//                                         progress:nil
//                                          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//                                              NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//#ifdef DEBUG_LOG_TAG
//                                              DEBUG_NSLOG(@"\n\n>>>>>>>>>>>>>  response data:  url:%@\n\n%@\n\n<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<\n\n",absolutelyUrl,responseString);
//#endif
//                                              if (success) {
//                                                  success(task, responseObject);
//                                              }
//                                          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//                                              if (failure) {
//                                                  failure(task, error);
//                                              }
//                                          }];
//    return dataTask;
//}

@end
