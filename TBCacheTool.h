//
//  TBCacheTool.h
//  SaasApp
//
//  Created by ToothBond on 15/12/2.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSTimeInterval kTBMemoryCacheTimeOutSeconds;

@interface TBCacheTool : NSObject

///只从内存中获取缓存数据
+ (id<NSCoding>)fetchMemoryCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict;
+ (id<NSCoding>)fetchCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict;
///异步获取缓存数据
+ (void)fetchCacheDataWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict block:(void(^)(id<NSCoding> object))block;
+ (void)saveCacheWithData:(id<NSCoding>)cacheData url:(NSString *)urlStr requestParams:(NSDictionary *)requestDict;
///只缓存到内存中
+ (void)saveMemoryCacheWithData:(id<NSCoding>)cacheData url:(NSString *)urlStr requestParams:(NSDictionary *)requestDict;
+ (void)removeCacheWithUrl:(NSString *)urlStr requestParams:(NSDictionary *)requestDict;

+ (NSInteger)getAllHttpCacheSize;
+ (void)removeAllHttpCache;

@end
