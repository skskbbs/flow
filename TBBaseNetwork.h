//
//  TBBaseNetwork.h
//  SaasApp
//
//  Created by ToothBond on 15/11/4.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "RequestDictionarySerializer.h"
#import "TokenRequestSerializer.h"
#import "ResponseDataSerializer.h"
#import "TBResponse.h"

/**
 *  外部接收通知用字符串
 */
extern NSString *const NetworkingReachableViaWWANNotification;
extern NSString *const NetworkingReachableViaWIFINotification;
extern NSString *const NetworkingNotReachableNotification;

typedef enum : NSUInteger {
    GET_METHOD,     //GET请求
    POST_METHOD,    //POST请求
    UPLOAD_DATA,    //上传文件的请求（POST）
}AFNetworkRequestMethod;

///接口缓存方式
typedef NS_ENUM(NSInteger,TBCacheType) {
    TBCacheTypeNoCache, //默认不缓存，直接请求网络数据
    TBCacheTypeOnlyMemoryCache, //只缓存到内存中，使用这种缓存策略请求接口，如果内存中缓存有数据，直接使用内存中的数据，不再请求网络
    TBCacheTypeFullCache,   //内存，磁盘二级缓存，先返回内存中的数据，再请求网络数据
};

typedef NS_ENUM(NSInteger,TBFetchDataPolicy) {
    TBFetchDataPolicyDefault,     //默认先获取缓存，再请求网络数据
    TBFetchDataPolicyUseCache,    //如果有缓存，只获取缓存
    TBFetchDataPolicyIgnoreCache, //忽略缓存，只请求网络
};

/**
 *  重复请求的处理方式
 */
typedef NS_ENUM(NSInteger,AFNetworkRepeatRequestOpeation) {
    /**
     *  取消前一次的请求，使用最新的请求,default
     */
    AFNetworkRepeatRequestOpeationRefresh,  //default
    /**
     *  维持前一次请求，阻止最新的请求
     */
    AFNetworkRepeatRequestOpeationProtect,
};

/**
 *  取消请求的类型
 */
typedef NS_ENUM(NSInteger,TBCancelType){
    TBCancelTypeDealloc,
    TBCancelTypeUser,
};

/**
 *  下载完成的block
 */
typedef void(^AFNetworkingConstructingBodyBlock)(id<AFMultipartFormData> formData);

/**
 *  下载进度
 */
typedef void (^UploadProgressBlock)(NSProgress *uploadProgress);


@protocol TBBaseNetworkProrocol <NSObject>

@optional

/**
 *  请求成功
 */
-(void)requestSuccess:(TBResponse *)response;

/**
 *  请求失败
 */
-(void)requestFailed:(TBResponse *)response;

/**
 *  用户取消请求
 */
-(void)requestCancel:(TBResponse *)response;

@end

@interface TBBaseNetwork : NSObject

+(void)showNetworkActivityIndicator:(BOOL)isShow;

+(void)startMonitoring;

+(void)stopMonitoring;

+(BOOL)isReachable;

+(BOOL)isReachableViaWWAN;

+(BOOL)isReachableViaWIFI;

@property (nonatomic,weak    ) id<TBBaseNetworkProrocol> delegate;

@property (nonatomic         ) NSInteger              flag;
@property (nonatomic,strong  ) NSNumber               *timeoutInterval;
@property (nonatomic         ) AFNetworkRequestMethod requestMethod;
@property (nonatomic,assign  ) BOOL isRequestWithFormData;//是否以表单的形式请求
@property (nonatomic,strong  ) NSString               *urlString;
@property (nonatomic,strong  ) NSDictionary           *requestDictionary;
@property (nonatomic,strong  ) NSMutableDictionary           *HTTPHeaderFieldsWithValues;
@property (nonatomic         ) BOOL                   isRunning;
@property (nonatomic,assign  ) AFNetworkRepeatRequestOpeation repeatRequestOpeationType;
@property (nonatomic         ) TBCacheType            cacheType;

@property (nonatomic, strong, readwrite) id <AFURLRequestSerialization>  requestSerializer;
@property (nonatomic, strong, readwrite) id <AFURLResponseSerialization> responseSerializer;

@property(nonatomic,strong)RequestDictionarySerializer  *requestDictionarySerializer;
@property(nonatomic,strong)id <ResponseDataSerialization>       responseDataSerializer;

/**
 *  构造上传数据的block
 */
@property (nonatomic, copy)     AFNetworkingConstructingBodyBlock  constructingBodyBlock;
/**
 *  检测下载进度的block
 */
@property (nonatomic, copy)     UploadProgressBlock    uploadProgressBlock;

///默认先加载缓存（如果配置了缓存策略）
-(void)startRequest;
///是否忽略缓存
-(void)startRequest:(TBFetchDataPolicy)policy;

-(void)cancelRequest;

-(void)uploadFile;
#pragma mark - 构造方法
/**
 *  请求实例构造方法
 *
 *  @param urlString          urlString
 *  @param requestDictionary  请求参数
 *  @param delegate           代理
 *  @param timeoutInterval    超时时间，设置nil 默认为30s
 *  @param flag               flag
 *  @param requestMethod      请求方式 GET_METHOD  POST_METHOD
 *  @param requestSerializer  AFHTTPRequestSerializer AFJSONRequestSerializer AFPropertyListRequestSerializer
 *  @param responseSerializer AFHTTPResponseSerializer AFJSONResponseSerializer AFXMLParserResponseSerializer AFXMLDocumentResponseSerializer AFPropertyListResponseSerializer AFImageResponseSerializer AFCompoundResponseSerializer
 *
 *  @return 请求实例对象
 */
+(instancetype)networkingWithUrlString:(NSString *)urlString
                     requestDictionary:(NSDictionary *)requestDictionary
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                       timeoutInterval:(NSNumber *)timeoutInterval
                                  flag:(NSInteger)flag
                         requestMethod:(AFNetworkRequestMethod)requestMethod
                  urlRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer
                 urlResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer;

/**
 *  便利构造器，不需要验证token
 *
 *  @param urlString         urlString
 *  @param requestDictionary requestDictionary description
 *  @param delegate          代理
 *
 *  @return 请求实例对象
 */
+(instancetype)networkingWithUrlString:(NSString *)urlString
                     requestDictionary:(NSDictionary *)requestDictionary
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                         requestMethod:(AFNetworkRequestMethod)requestMethod;
+(instancetype)networkingWithUrlString:(NSString *)urlString
                              delegate:(id<TBBaseNetworkProrocol>)delegate
                         requestMethod:(AFNetworkRequestMethod)requestMethod;

/**
 *  便利构造器，需要验证token,必须先登录
 *
 *  @param urlString urlString
 *  @param delegate  代理
 *
 *  @return 请求实例对象
 */
+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                                  delegate:(id<TBBaseNetworkProrocol>)delegate
                             requestMethod:(AFNetworkRequestMethod)requestMethod;

+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                             requestMethod:(AFNetworkRequestMethod)requestMethod;

#pragma mark - block形式请求
//+(NSURLSessionDataTask *)POST:(NSString *)URLString
//                   parameters:(id)parameters
//                      success:(void (^)(NSURLSessionDataTask *task, TBResponse *resp))success
//                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;
//
//+(NSURLSessionDataTask *)POST:(NSString *)URLString
//                     parameters:(id)parameters
//                timeoutInterval:(NSNumber *)timeoutIntervall
//           urlRequestSerializer:(id<AFURLRequestSerialization>)requestSerializer
//          urlResponseSerializer:(id<AFURLResponseSerialization>)responseSerializer
//                        success:(void (^)(NSURLSessionDataTask *task, TBResponse *resp))success
//                        failure:(void(^)(NSURLSessionDataTask *task, NSError *error))failure;
//
//+(NSURLSessionDataTask *)GET:(NSString *)URLString
//                   parameters:(id)parameters
//                      success:(void (^)(NSURLSessionDataTask *task, id respData))success
//                      failure:(void (^)(NSURLSessionDataTask *task, NSError *error))failure;

@end
