//
//  TBCacheTool.m
//  SaasApp
//
//  Created by ToothBond on 15/12/2.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "TBCacheTool.h"
#import "TBCacheObject.h"
#import "YYCache.h"

static NSString *const kNetworkCacheFilePath = @"aiyaku_data";
static YYCache *_dataCache;

NSTimeInterval kTBMemoryCacheTimeOutSeconds = 300;// 5分钟的cache过期时间
static NSTimeInterval kTBDiskCacheTimeOutSeconds = 3600 * 24 * 7;
static NSUInteger kTBDiskCacheSizeLimit = 1024 * 1024 * 100;

@interface TBCacheTool ()

//@property (nonatomic,strong)NSCache *cache;

@end

@implementation TBCacheTool

+ (void)initialize
{
    _dataCache = [YYCache cacheWithName:kNetworkCacheFilePath];
    _dataCache.memoryCache.ageLimit = kTBMemoryCacheTimeOutSeconds;
    _dataCache.diskCache.ageLimit = kTBDiskCacheTimeOutSeconds;
    _dataCache.diskCache.costLimit = kTBDiskCacheSizeLimit;
}

//+ (instancetype)sharedInstance
//{
//    static TBCacheTool *sharedInstance;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken,^{
//        sharedInstance = [[TBCacheTool alloc] init];
//    });
//    return sharedInstance;
//}

#pragma mark - public

+ (id<NSCoding>)fetchMemoryCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
    return [_dataCache.memoryCache objectForKey:key];
}

+ (id<NSCoding>)fetchCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
//    TBCacheObject *cacheObject = [self.cache objectForKey:key];
//    if (cacheObject.isOutdated || cacheObject.isEmpty) {
//        return nil;
//    }else{
//        return cacheObject.content;
//    }
    
    return [_dataCache objectForKey:key];
}

+ (void)fetchCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict block:(void(^)(id<NSCoding> object))block
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
    [_dataCache objectForKey:key withBlock:^(NSString * _Nonnull key, id<NSCoding>  _Nonnull object) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) {
                block(object);
            }
        });
    }];
}

+ (NSInteger)getAllHttpCacheSize
{
    return [_dataCache.diskCache totalCost];
}

+ (void)removeAllHttpCache
{
    [_dataCache.diskCache removeAllObjects];
}

+ (void)saveCacheWithData:(id<NSCoding>)cacheData url:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
//    TBCacheObject *cacheObject = [self.cache objectForKey:key];
//    if (cacheObject == nil) {
//        cacheObject = [[TBCacheObject alloc] init];
//    }
//    [cacheObject updateContent:cacheData];
//    [self.cache setObject:cacheObject forKey:key];
//    
    [_dataCache setObject:cacheData forKey:key withBlock:nil];
}

+ (void)saveMemoryCacheWithData:(id<NSCoding>)cacheData url:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
    [_dataCache.memoryCache setObject:cacheData forKey:key];
}

+ (void)removeCacheWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSString *key = [TBCacheTool keyWithUrl:urlStr requestParams:requestDict];
    [_dataCache removeObjectForKey:key withBlock:nil];
}

#pragma mark - private
+(NSString *)keyWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict
{
    NSMutableDictionary *cacheDict = [[NSMutableDictionary alloc] initWithDictionary:requestDict];
    [cacheDict removeObjectForKey:@"authcode"];
    NSString *keyStr = [NSString stringWithFormat:@"%@%@",urlStr,cacheDict];
    NSString *cacheKey = [StringUtils MD5encode:keyStr];
    DEBUG_NSLOG(@"md5 cache key : %@",cacheKey);
    return cacheKey;
}

//#pragma mark - getter
//-(NSCache *)cache
//{
//    if (_cache == nil) {
//        _cache = [[NSCache alloc] init];
//        _cache.countLimit = kTBCacheCountLimit;
//    }
//    return _cache;
//}

@end
