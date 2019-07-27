//
//  TBResponse.m
//  SaasApp
//
//  Created by ToothBond on 15/11/10.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "TBResponse.h"

@implementation TBResponse

-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData
{
    NSString *statusMsg = network_error;
    if (status == TBURLSuccessCodeTokenFailure || status == TBURLSuccessCodeTokenExpire) {
        statusMsg = @"账号过期，请重新登录";
    }
    else if(status == TBURLSuccessCodeServerError){
        statusMsg = @"服务器出错！";
    }
    else if(status == TBURLSuccessCodeSuccess){
        statusMsg = @"请求成功";
    }
    return [self initWithResponseStatus:status statusMsg:statusMsg dataTask:dataTask flag:flag responseData:responseData];
}

-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status statusMsg:(NSString*)statusMsg dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData
{
    self = [super init];
    if (self) {
        _status = status;
        _statusMsg = statusMsg;
        _dataTask = dataTask;
        _flag = flag;
        _responseData = responseData;
    }
    return self;
}

-(instancetype)initWithDataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag responseData:(id)responseData error:(NSError *)error
{
    self = [super init];
    if (self) {
        _status = TBURLSuccessCodeNoNetwork;
        _dataTask = dataTask;
        _statusMsg = network_error;
        _flag = flag;
        _responseData = responseData;
    }
    return self;
}

-(instancetype)initWithResponseStatus:(TBURLSuccessCode)status dataTask:(NSURLSessionDataTask *)dataTask flag:(NSInteger)flag getServerTimeFlag:(NSInteger)getServerTimeFlag responseData:(id)responseData
{
    if (self = [super init]) {
        _status = status;
        _dataTask = dataTask;
        _flag = flag;
        _getServerTimeFlag = getServerTimeFlag;
        _responseData = responseData;
        
    }
    return self;
}

//-(TBURLResponseStatus)responseStatusWithError:(NSError *)error
//{
//    if (error) {
//        TBURLResponseStatus status = TBURLResponseStatusErrorNoNetwork;
//        
//        // 除了超时以外，所有错误都当成是无网络
//        if (error.code == NSURLErrorTimedOut) {
//            status = TBURLResponseStatusErrorNoNetwork;
//        }
//        return status;
//    } else {
//        return TBURLResponseStatusSuccess;
//    }
//}

@end
