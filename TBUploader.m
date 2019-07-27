//
//  TBUploader.m
//  SaasApp
//
//  Created by ToothBond on 16/3/28.
//  Copyright © 2016年 ToothBond. All rights reserved.
//

#import "TBUploader.h"
#import "TBFileManager.h"

@implementation TBUploadObject

+(instancetype)tbUploadObjectWithKey:(NSString *)key fileName:(NSString *)fileName mineType:(NSString *)mineType filePath:(NSString *)filePath fileData:(NSData *)fileData
{
    TBUploadObject *obj = [[TBUploadObject alloc] init];
    obj.key = key;
    obj.fileName = fileName;
    obj.filePath = filePath;
    obj.mineType = mineType;
    obj.fileData = fileData;
    return obj;
}

- (NSString *)description
{
    NSString *point = [super description];
    NSMutableString *descStr = [[NSMutableString alloc] init];
    [descStr appendString:[NSString stringWithFormat:@"< %@ >, key = %@; ",point,self.key]];
    [descStr appendString:[NSString stringWithFormat:@"fileName = %@; ",self.fileName]];
    [descStr appendString:[NSString stringWithFormat:@"mineType = %@; ",self.mineType]];
    if ([StringUtils isNotEmptyString:self.filePath]) {
        [descStr appendString:[NSString stringWithFormat:@"filePath = %@; ",self.filePath]];
    }
    if (self.fileData) {
        [descStr appendString:[NSString stringWithFormat:@"fileData = %lu; ",(unsigned long)self.fileData.length]];
    }
    return descStr;
}

-(id)copyWithZone:(NSZone *)zone
{
    TBUploadObject *object = [[TBUploadObject alloc] init];
    object.key = [self.key copy];
    object.fileName = [self.fileName copy];
    object.filePath = [self.filePath copy];
    object.mineType = [self.mineType copy];
    object.fileData = [self.fileData copy];
    return object;
}

@end

@interface TBUploader()

@property(nonatomic,strong)AFHTTPSessionManager *manager;
@property(nonatomic,strong)NSURLSessionDataTask *httpOperation;
@property(nonatomic,strong)NSURLSessionUploadTask *uploadTask;
@property(nonatomic)    TBCancelType cancelType;

@end

@implementation TBUploader

#pragma  mark - 初始化
-(instancetype) init
{
    self = [super init];
    if (self) {
        [self defaultConfig];
    }
    return self;
}

#pragma mark 构造方法
+(instancetype)networkingWithUrlString:(NSString *)urlString
                     requestDictionary:(NSDictionary *)requestDictionary
                              delegate:(id<TBUploaderDelegate>)delegate
                                  flag:(NSInteger )flag
                  urlRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer
                 urlResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer
{
    if ([StringUtils isEmptyString:urlString]) {
        urlString = @"user/uploadfile";
    }
    TBUploader *aiyaApi        = [[TBUploader alloc]init];
    aiyaApi.urlString          = [NSString stringWithFormat:@"%@/%@",TBBaseURL,urlString];
    aiyaApi.requestDictionary  = requestDictionary;
    aiyaApi.flag               = flag;
    aiyaApi.delegate           = delegate;
    aiyaApi.requestSerializer  = requestSerializer;
    aiyaApi.responseSerializer = responseSerializer;
    aiyaApi.requestDictionarySerializer = [[RequestDictionarySerializer alloc] init];
    NSDictionary *header = @{@"Content-Type":@"application/json; charset=utf-8"};
    aiyaApi.HTTPHeaderFieldsWithValues = [header mutableCopy];
    return aiyaApi;
}

+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                                  delegate:(id<TBUploaderDelegate>)delegate
{
    TBUploader *network =  [[self class] networkingWithUrlString:urlString
                                                  requestDictionary:nil
                                                           delegate:delegate
                                                               flag:0
                                               urlRequestSerializer:nil
                                              urlResponseSerializer:nil];
    RequestDictionarySerializer *serializer = [[TokenRequestSerializer alloc] init];
    network.requestDictionarySerializer = serializer;
    
    return network;
}

-(void)defaultConfig
{
    self.manager = [AFHTTPSessionManager manager];
    self.timeoutInterval = 120.0;
    self.isRunning = NO;
    self.repeatRequestOpeationType = AFNetworkRepeatRequestOpeationRefresh;
}

-(void)dealloc
{
    self.isRunning = NO;
    self.cancelType = TBCancelTypeDealloc;
    [self.httpOperation cancel];
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
    NSMutableDictionary * dict = [NSMutableDictionary dictionary];
//    [dict addEntriesFromDictionary:@{@"wms-token":data.token}];
    [dict addEntriesFromDictionary:self.requestDictionary];
    self.requestDictionary = [dict copy];
    
    if (self.HTTPHeaderFieldsWithValues) {
        NSArray *allKeys = self.HTTPHeaderFieldsWithValues.allKeys;
        for (NSString *headerField in allKeys) {
            NSString *value = [self.HTTPHeaderFieldsWithValues valueForKey:headerField];
            [self.manager.requestSerializer setValue:value forHTTPHeaderField:headerField];//modify by wj
        }
    }
}
- (void)setupUploadParamsWithImage:(UIImage*)image
{
    NSData * fixdImageData = UIImageJPEGRepresentation(image, 0.9);
    
    //判断是否修改了图片
    TBUploadObject *uploadObject = [TBUploadObject tbUploadObjectWithKey:@"image"
                                                                fileName:[TBFileManager createRandomFileNameWithSuffix:@".jpg"]
                                                                mineType:@"image/jpeg"
                                                                filePath:nil
                                                                fileData:fixdImageData];
    NSMutableArray *fileArray = [[NSMutableArray alloc] initWithObjects:uploadObject, nil];
    self.requestFiles = fileArray;
    self.uploadProgressBlock = ^(__kindof NSProgress *_progress) {
        DEBUG_NSLOG(@"进度进度：%lld/%lld,%@",_progress.completedUnitCount,_progress.totalUnitCount,_progress.localizedDescription);
    };
}
#pragma mark - public
-(void)uploadImage:(UIImage*)image
{
    if (image) {
        [self setupUploadParamsWithImage:image];
        [self startUpload];
    }
    
}
-(void)startUpload
{
    if (self.urlString.length <= 0) {
        return;
    }
    if (_isRunning) {
        if (self.repeatRequestOpeationType == AFNetworkRepeatRequestOpeationRefresh) {
            DEBUG_NSLOG(@"refresh request : %@",self.urlString);
            [self cancelUpload];
        }else if(self.repeatRequestOpeationType == AFNetworkRepeatRequestOpeationProtect){
            DEBUG_NSLOG(@"cancel request : %@",self.urlString);
            return;
        }
    }
    
    _isRunning = YES;
    [self setupRequestHeader];
    
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
    
    // 设置超时时间
    if (self.timeoutInterval) {
        [self.manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
        self.manager.requestSerializer.timeoutInterval = self.timeoutInterval;
        [self.manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    }
    

    __weak TBUploader *weakSelf = self;
    //处理入参 block内部中引用外部变量
    __block NSDictionary *requestDict = [self.requestDictionarySerializer transformRequestDictionaryWithInputDictionary:self.requestDictionary];
    //检查token
    if (requestDict == nil) {
        DEBUG_NSLOG(@"================ token auth failure =======");
        TBResponse *response = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeTokenFailure
                                                                dataTask:nil
                                                                     flag:weakSelf.flag
                                                             responseData:nil];
        if (self.delegate && [weakSelf.delegate respondsToSelector:@selector(requestFailed:)]) {
            [weakSelf.delegate requestFailed:response];
        }
        return;
    }

//    DEBUG_NSLOG(@"\n\n====================    network Request   start\n\nurl : %@\nPOST Params: \n%@\n\n====================    network Request   end\n\n",self.urlString,[requestDict.mj]);
    self.httpOperation = [self.manager POST:self.urlString
                                 parameters:requestDict
                  constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
                            //组装file数据
                              for (int i=0; i<weakSelf.requestFiles.count; i++) {
                                  if (i == 0) {
                                      DEBUG_NSLOG(@"POST FILE : \n ===========");
                                  }
                                  TBUploadObject *obj = [weakSelf.requestFiles objectAtIndex:i];
                                  if (obj.fileData) {
                                      [formData appendPartWithFileData:obj.fileData name:obj.key fileName:obj.fileName mimeType:obj.mineType];
                                  }else if(obj.filePath){
                                      [formData appendPartWithFileURL:[NSURL fileURLWithPath:obj.filePath] name:obj.key fileName:obj.fileName mimeType:obj.mineType error:nil];
                                  }
                                  DEBUG_NSLOG(@"%@",obj.description);
                                  if (i == weakSelf.requestFiles.count - 1) {
                                      DEBUG_NSLOG(@"\n ========================");
                                  }
                              }
                      
                  }
                                   progress:weakSelf.uploadProgressBlock
                                    success:^(NSURLSessionDataTask *task, id responseObject) {
                                        weakSelf.isRunning = NO;
                                        NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
                                        DEBUG_NSLOG(@"\n\nurl:%@\n\n>>>>>>>>>>>>>>>>>>>>>           response data:\n%@\n\n<<<<<<<<<<<<<<<<<<<<<<\n\n",weakSelf.urlString,responseString);
                                        
                                        //防止断网情况下，服务器返回的数据为空
                                        
                                        if ([StringUtils isEmptyString:responseString]) {
                                            TBResponse *failResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeNoNetwork
                                                                                                        dataTask:weakSelf.httpOperation
                                                                                                             flag:weakSelf.flag
                                                                                                     responseData:nil];
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestFailed:)]) {
                                                [weakSelf.delegate requestFailed:failResponse];
                                            }
                                            return ;
                                        }
                                        
                                        //加入直接返回上传成功地址的请求
                                        id responseData = nil;
                                        NSError *error = nil;
                                        TBURLSuccessCode successCode = TBURLSuccessCodeNoData;
                                        responseData = [self.responseDataSerializer transformResponseDataWithInputData:responseObject error:&error];
                                        if (error == nil && responseData && [responseData objectForKey:@"status"]) {
                                            successCode = [responseData[@"status"] integerValue];
                                            
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
                                        NSString *data = nil;
                                        if (successCode == 200 && [responseData objectForKey:@"data"]) {
                                            data = responseData[@"data"];
                                            [weakSelf.delegate onUploadImageSuccessWithUrl:data];
                                        }else{
                                            NSString *msg = nil;
                                            if ([responseData objectForKey:@"msg"]) {
                                                msg = [responseData objectForKey:@"msg"];
                                            }
                                            TBResponse *successResponse = [[TBResponse alloc] initWithResponseStatus:successCode
                                                                                                           statusMsg:msg
                                                                                                            dataTask:self.httpOperation
                                                                                                                flag:self.flag
                                                                                                        responseData:responseObject];
                                            if (self.delegate && [self.delegate respondsToSelector:@selector(requestSuccess:)]) {
                                                [self.delegate requestSuccess:successResponse];
                                            }
                                        }
                                        
                                    }
                                    failure:^(NSURLSessionDataTask *task, NSError *error) {
                                        weakSelf.isRunning = NO;
                                        if (weakSelf.cancelType == TBCancelTypeUser) {
                                            DEBUG_NSLOG(@" =========================\n %@ \n=========================" , @"Request Cancel");
                                            TBResponse *cancelResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeNoNetwork
                                                                                                          dataTask:weakSelf.httpOperation
                                                                                                               flag:weakSelf.flag
                                                                                                       responseData:nil];
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestCancel:)]) {
                                                [weakSelf.delegate requestCancel:cancelResponse];
                                            }
                                        }else{
                                            DEBUG_NSLOG(@" =========================\n %@ \n%@ \n=========================" ,
                                                        error.localizedDescription,
                                                        error.userInfo.descriptionInStringsFileFormat);
                                            TBResponse *failResponse = [[TBResponse alloc] initWithResponseStatus:TBURLSuccessCodeNoNetwork
                                                                                                        dataTask:weakSelf.httpOperation
                                                                                                             flag:weakSelf.flag
                                                                                                     responseData:nil];
                                            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(requestFailed:)]) {
                                                [weakSelf.delegate requestFailed:failResponse];
                                            }

                                        }
                                    }];
    

    

}

-(void)cancelUpload
{
    [self.httpOperation cancel];
    _isRunning = NO;
}

@end
