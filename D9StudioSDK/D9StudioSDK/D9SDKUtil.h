//
//  D9SDKUtil.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-31.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

//Functions for Encoding Data.
@interface NSData (D9Encode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
@end

//Functions for Encoding String.
@interface NSString (D9Encode)
- (NSString *)MD5EncodedString;
- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key;
- (NSString *)base64EncodedString;
- (NSString *)URLEncodedString;
- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding;
@end

//@interface NSString (D9Util)
//
//+ (NSString *)GUIDString;
//
//@end

@interface D9SDKUtil : NSObject

+ (void) showAlertViewWithMsg:(NSString *)msg;
+ (void) showSuccessAlertViewWithMsg:(NSString *)msg;
+ (NSString *) getIPAddress;
+ (NSString *) getMacAddress;
+ (NSString *) toUTF8ConvertString:(NSString *) uglyString;

+ (NSString *) getLowerMacAddress;

+ (void) saveToKeyChainUname:(NSString *)username Pwd:(NSString *)password AppId:(NSString *)appId;
//+ (NSArray *) readFromKeyChainAppId:(NSString *)appId;
+ (NSString *) readUnameFromKeyChainAppId:(NSString *)appId;
+ (NSString *) readPwdFromKeyChainAppId:(NSString *)appId;
+ (void) deleteInKeyChainAppId:(NSString *)appId;

@end