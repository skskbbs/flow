//
//  RequestDictionarySerializer.h
//  SaasApp
//
//  Created by ToothBond on 15/11/6.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RequestDictionarySerializer : NSObject
///是否过滤value为@""的入参，默认=NO过滤
@property(nonatomic,assign)BOOL dontFilterEmptyRequestParamKey;

-(NSDictionary *)transformRequestDictionaryWithInputDictionary:(NSDictionary *)inputDictionary;

@end
