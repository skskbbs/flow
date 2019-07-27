//
//  TokenRequestSerializer.m
//  SaasApp
//
//  Created by ToothBond on 15/11/9.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "TokenRequestSerializer.h"


@implementation TokenRequestSerializer

-(NSDictionary *)transformRequestDictionaryWithInputDictionary:(NSDictionary *)inputDictionary
{
    NSDictionary * superDict = [super transformRequestDictionaryWithInputDictionary:inputDictionary];
    NSMutableDictionary *retDict = [NSMutableDictionary dictionaryWithDictionary:superDict];
    if ([superDict valueForKey:@"token"] == nil) {
//        NSString *token = [[UserManager sharedInstance] userToken];
        NSString *token = nil;
        if ([StringUtils isNotEmptyString:token]) {
            [retDict setObject:token forKey:@"token"];
        }
        
    }
    
    return retDict;
}


@end
