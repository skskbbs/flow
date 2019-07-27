//
//  TBNetworkConfig.h
//  SaasApp
//
//  Created by ToothBond on 15/10/30.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#ifndef TBNetworkConfig_h
#define TBNetworkConfig_h

#endif 

#define DEBUG_LOG_TAG     //取消注释，即可查看网络请求log

#define TEST

#ifdef DEV
#define DEV_JAVA_SYS
#endif
#ifdef TEST
#define TEST_JAVA_SYS
#endif
#ifdef PROD
#define PRODUCT_JAVA_SYS
#endif


#ifdef PRODUCT_JAVA_SYS
static NSString *TBBaseURL  = @"http://www.xiangjiaoyu.vip/api";
static NSString *TBMoileResUrl  = @"http://testm.51aiyaku.com";
static NSString *AiyakuImgPrefix =    @"http://www.xiangjiaoyu.vip";
static NSString *AiyakuJobDomain = @"http://testjob.51aiyaku.com";
#endif

#ifdef TEST_JAVA_SYS
static NSString *TBBaseURL  = @"http://yhq.kuaimacode.com/api";
static NSString *TBMoileResUrl  = @"http://testm.51aiyaku.com";
static NSString *AiyakuImgPrefix =    @"http://yhq.kuaimacode.com";
static NSString *AiyakuJobDomain = @"http://testjob.51aiyaku.com";

#endif

#ifdef DEV_JAVA_SYS
static NSString *TBBaseURL  = @"http://192.168.3.87:5003";//
static NSString *TBMoileResUrl  = @"http://testm.51aiyaku.com";
static NSString *AiyakuImgPrefix =    @"https://kfzuultest.aiyaku.com:5443";
static NSString *AiyakuJobDomain = @"http://testjob.51aiyaku.com";
#endif

/**
 *  网络请求底层响应
 */
typedef NS_ENUM(NSInteger, TBURLResponseStatus) {
    /**
     *  请求成功
     */
    TBURLResponseStatusSuccess = 200,
    /**
     *  用户取消
     */
    TBURLResponseStatusCancel = -4,
    /**
     *  认证失败
     */
    TBURLResponseStatusAuthFailure = -3,
    /**
     *  请求超时
     */
    TBURLResponseStatusErrorTimeout = -2,
    /**
     *  连接失败
     */
    TBURLResponseStatusErrorNoNetwork = -1,

};

/**
 *  接口返回码
 */
typedef NS_ENUM(NSInteger, TBURLSuccessCode) {
    /**
     *  请求成功
     */
    TBURLSuccessCodeSuccess = 1,
    /**
     *  暂无数据
     */
    TBURLSuccessCodeNoData = 203,
    /**
     *  异地登录
     */
    TBURLSuccessCodeTokenFailure = 401,
    /**
     *  token过期
     */
    TBURLSuccessCodeTokenExpire = 902,
    /**
     *  角色权限失效
     */
    TBURLSuccessCodeAuthFailure = 403,
    /**
     *  缺少参数
     */
    TBURLSuccessCodeParamsError = 412,
    /**
     *  口令验证超时
     */
    TBURLSuccessCodeTimeout = 408,
    /**
     *  服务器出错
     */
    TBURLSuccessCodeServerError = 0,
    /**
     *  无网络
     */
    TBURLSuccessCodeNoNetwork = -1,
    /**
     *  强制补全资料
     */
    TBURLSuccessCodeCompleteInfo = 510,
};

#define API_VERSION  @"1"

static NSTimeInterval kTBNetworkTimeoutSeconds = 30.0f;// 请求超时30s

/**
 *  时间间隔参数类型
 */
typedef NS_ENUM(NSInteger, BespeakTimeIntervalType) {
    BespeakTimeIntervalTypeDay = 1,
    BespeakTimeIntervalTypeWeek = 2,
    BespeakTimeIntervalTypeMonth = 3,
    BespeakTimeIntervalTypeYear = 4,
    BespeakTimeIntervalTypeOther = 5,
};

typedef NS_ENUM(NSInteger,SMSAuthCodeType) {
    SMSAuthCodeTypeRegster = 1,
    SMSAuthCodeTypeFindPsw = 2,
};
