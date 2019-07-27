//
//  RequestDictionarySerializer.m
//  SaasApp
//
//  Created by ToothBond on 15/11/6.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import "RequestDictionarySerializer.h"
#import "TBNetworkConfig.h"
#import "TBUserManager.h"

@implementation RequestDictionarySerializer

-(NSDictionary *)transformRequestDictionaryWithInputDictionary:(NSDictionary *)inputDictionary
{
    NSMutableDictionary *retDict = [NSMutableDictionary dictionary];
    if (self.dontFilterEmptyRequestParamKey) {
        [retDict addEntriesFromDictionary:inputDictionary];
    }else{
        [inputDictionary.allKeys enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id value = [inputDictionary objectForKey:obj];
            if ([value isKindOfClass:[NSString class]]) {
                NSString *stringValue = (NSString *)value;
                if (stringValue.length > 0 && ![stringValue isEqualToString:@""]) {
                    [retDict setObject:value forKey:obj];
                }
            }else{
                [retDict setObject:value forKey:obj];
            }
        }];
    }
    
    NSInteger user_id = [TBUserManager sharedInstance].user_id;
    if (user_id) {
        [retDict setObject:@(user_id) forKey:@"user_id"];
    }
    
    return retDict;
}


@end
