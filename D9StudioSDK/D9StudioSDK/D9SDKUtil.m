//
//  D9SDKUtil.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-31.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9SDKUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonHMAC.h>
#import "GTMBase64.h"

#pragma mark - NSData (D9Encode)

@implementation NSData (D9Encode)

- (NSString *)MD5EncodedString
{
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5([self bytes], [self length], result);
	
	return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{
	NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    void *buffer = malloc(CC_SHA1_DIGEST_LENGTH);
    CCHmac(kCCHmacAlgSHA1, [keyData bytes], [keyData length], [self bytes], [self length], buffer);
	
	NSData *encodedData = [NSData dataWithBytesNoCopy:buffer length:CC_SHA1_DIGEST_LENGTH freeWhenDone:YES];
    return encodedData;
}

- (NSString *)base64EncodedString
{
	return [GTMBase64 stringByEncodingData:self];
}

@end

#pragma mark - NSString (D9Encode)

@implementation NSString (D9Encode)

- (NSString *)MD5EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString];
}

- (NSData *)HMACSHA1EncodedDataWithKey:(NSString *)key
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] HMACSHA1EncodedDataWithKey:key];
}

- (NSString *) base64EncodedString
{
	return [[self dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
}

- (NSString *)URLEncodedString
{
	return [self URLEncodedStringWithCFStringEncoding:kCFStringEncodingUTF8];
}

- (NSString *)URLEncodedStringWithCFStringEncoding:(CFStringEncoding)encoding
{
	return [(NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)[[self mutableCopy] autorelease], NULL, CFSTR("￼=,!$&'()*+;@?\n\"<>#\t :/"), encoding) autorelease];
}

@end

//#pragma mark - NSString (D9Util)
//
//@implementation NSString (D9Util)
//
//+ (NSString *)GUIDString
//{
//	CFUUIDRef theUUID = CFUUIDCreate(NULL);
//	CFStringRef string = CFUUIDCreateString(NULL, theUUID);
//	CFRelease(theUUID);
//	return [(NSString *)string autorelease];
//}
//
//@end

#import "UIKit/UIKit.h"

@implementation D9SDKUtil

+ (void) showAlertViewWithMsg:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"错误"
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"确定"
                                          otherButtonTitles:nil];
    [alert show];
    [alert autorelease];
}

@end
