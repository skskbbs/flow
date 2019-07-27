//
//  ResponseDataSerializer.h
//  SaasApp
//
//  Created by ToothBond on 15/11/6.
//  Copyright © 2015年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResponseDataSerialization <NSObject>

@required
+(id)transformResponseDataWithInputData:(id)data error:(NSError **)error;

-(id)transformResponseDataWithInputData:(id)data error:(NSError **)error;

@end

@interface ResponseDataSerializer : NSObject<ResponseDataSerialization>

@end
