//
//  TBResponse.h
//  SaasApp
//
//  Created by ToothBond on 15/11/10.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBNetworkConfig.h"
@class AFHTTPRequestOperation;

@interface TBResponse : NSObject

@property (nonatomic,strong,readonly) id                     responseData;
@property (nonatomic,assign,readonly) TBURLSuccessCode       status;
@property (nonatomic,copy,readonly)   NSString *statusMsg;
@property (nonatomic,strong,readonly) NSURLSessionDataTask *dataTask;
@property (nonatomic,assign,readonly) NSInteger              flag;
@property (nonatomic,assign,readonly) NSInteger              getServerTimeFlag;


-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData;

-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status statusMsg:(NSString*)statusMsg dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData;

-(instancetype)initWithDataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData error:(NSError *)error;

//增加获取服务器时间flag
-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag getServerTimeFlag:(NSInteger)getServerTimeFlag responseData:(id)responseData;

@end
