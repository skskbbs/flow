//
//  TBUploader.h
//  SaasApp
//
//  Created by ToothBond on 16/3/28.
//  Copyright © 2016年 ToothBond. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBBaseNetwork.h"



@interface TBUploadObject : NSObject<NSCopying>

@property(nonatomic,copy) NSString * key;
@property(nonatomic,copy) NSString * fileName;
@property(nonatomic,copy) NSString * mineType;
@property(nonatomic,copy) NSString * filePath;
@property(nonatomic,strong) NSData * fileData;

+(instancetype)tbUploadObjectWithKey:(NSString *)key fileName:(NSString *)fileName mineType:(NSString *)mineType filePath:(NSString *)filePath fileData:(NSData *)fileData;

@end

@protocol TBUploaderDelegate <TBBaseNetworkProrocol>

@optional
- (void)onUploadImageSuccessWithUrl:(NSString*)url;

@end

@interface TBUploader : NSObject

@property (nonatomic,weak    ) id<TBUploaderDelegate> delegate;

@property (nonatomic         ) NSInteger              flag;
@property (nonatomic,assign  ) NSTimeInterval         timeoutInterval;
@property (nonatomic,strong  ) NSString               *urlString;
@property (nonatomic,strong  ) NSDictionary           *requestDictionary;
@property (nonatomic,strong  ) NSMutableArray         *requestFiles;
@property (nonatomic,strong  ) NSMutableDictionary    *HTTPHeaderFieldsWithValues;
@property (nonatomic         ) BOOL                   isRunning;
@property (nonatomic,assign  ) AFNetworkRepeatRequestOpeation repeatRequestOpeationType;
@property (nonatomic         ) BOOL                   shouldCache;

@property (nonatomic, strong, readwrite) id <AFURLRequestSerialization>  requestSerializer;
@property (nonatomic, strong, readwrite) id <AFURLResponseSerialization> responseSerializer;

@property(nonatomic,strong)RequestDictionarySerializer  *requestDictionarySerializer;
@property(nonatomic,strong)id <ResponseDataSerialization>       responseDataSerializer;

/**
 *  构造上传数据的block
 */
@property (nonatomic, copy)     AFNetworkingConstructingBodyBlock  constructingBodyBlock;
/**
 *  检测下载进度的block
 */
@property (nonatomic, copy)     UploadProgressBlock    uploadProgressBlock;

+(instancetype)authNetworkingWithUrlString:(NSString *)urlString
                                  delegate:(id<TBUploaderDelegate>)delegate;
//上传图片
-(void)uploadImage:(UIImage*)image;

-(void)cancelUpload;
@end
