//
//  TBCacheObject.m
//  SaasApp
//
//  Created by ToothBond on 15/12/2.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "TBCacheObject.h"
#import "TBCacheTool.h"

@interface TBCacheObject ()

@property (nonatomic, copy, readwrite) NSData *content;
@property (nonatomic, copy, readwrite) NSDate *lastUpdateTime;

@end

@implementation TBCacheObject

-(instancetype)initWithContent:(NSData *)content
{
    self = [super init];
    if (self) {
        self.content = content;
    }
    return self;
}

#pragma mark - public
-(void)updateContent:(NSData *)content
{
    self.content = content;
}

#pragma mark - getter setter
- (BOOL)isEmpty
{
    return self.content == nil;
}

- (BOOL)isOutdated
{
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime];
    return timeInterval > kTBMemoryCacheTimeOutSeconds;
}

-(void)setContent:(NSData *)content
{
    _content = [content copy];
    self.lastUpdateTime = [NSDate dateWithTimeIntervalSinceNow:0];
}

@end
