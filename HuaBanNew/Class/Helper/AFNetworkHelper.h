//
//  AFNetworkHelper.h
//  TestRequest
//
//  Created by chengxianghe on 15/9/23.
//  Copyright © 2015年 CXH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

FOUNDATION_EXPORT void TestLog(NSString *format, ...) NS_FORMAT_FUNCTION(1,2);

@interface AFNetworkHelper : NSObject

+ (BOOL)checkJson:(id)json withValidator:(id)validatorJson;

+ (NSString *)urlStringWithOriginUrlString:(NSString *)originUrlString
                          appendParameters:(NSDictionary *)parameters;

+ (void)addDoNotBackupAttribute:(NSString *)path;

+ (NSString *)md5StringFromString:(NSString *)string;

+ (NSString *)appVersionString;

+ (NSDictionary *)baseRequestDict;

+ (NSString *)baseUrlString;

+ (NSString *)mimeTypeForFileAtPath:(NSString *)path;

+ (NSString*)urlEncode:(NSString*)str;
+ (NSString*)urlDecoded:(NSString *)str;

@end
