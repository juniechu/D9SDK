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
	return [[[self dataUsingEncoding:NSUTF8StringEncoding] MD5EncodedString] lowercaseString];
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
#import "SFHFKeychainUtils.h"

#include <ifaddrs.h>
#include <arpa/inet.h>

#include <sys/socket.h> // Per msqr
#include <sys/sysctl.h>
#include <net/if.h>
#include <net/if_dl.h>

#define kD9URLSchemePrefix              @"D9_"
#define kD9KeychainServiceNameSuffix    @"_ServiceName"
#define kD9KeychainUsername             @"D9Username"
#define kD9keychainPassword             @"D9Password"

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

+ (NSString *)getIPAddress {
    
    NSString *address = @"errorIP";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0) {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL) {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

+ (NSString *) getMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02X-%02X-%02X-%02X-%02X-%02X",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *) getLowerMacAddress
{
    int                 mgmtInfoBase[6];
    char                *msgBuffer = NULL;
    size_t              length;
    unsigned char       macAddress[6];
    struct if_msghdr    *interfaceMsgStruct;
    struct sockaddr_dl  *socketStruct;
    NSString            *errorFlag = NULL;
    
    // Setup the management Information Base (mib)
    mgmtInfoBase[0] = CTL_NET;        // Request network subsystem
    mgmtInfoBase[1] = AF_ROUTE;       // Routing table info
    mgmtInfoBase[2] = 0;
    mgmtInfoBase[3] = AF_LINK;        // Request link layer information
    mgmtInfoBase[4] = NET_RT_IFLIST;  // Request all configured interfaces
    
    // With all configured interfaces requested, get handle index
    if ((mgmtInfoBase[5] = if_nametoindex("en0")) == 0)
        errorFlag = @"if_nametoindex failure";
    else
    {
        // Get the size of the data available (store in len)
        if (sysctl(mgmtInfoBase, 6, NULL, &length, NULL, 0) < 0)
            errorFlag = @"sysctl mgmtInfoBase failure";
        else
        {
            // Alloc memory based on above call
            if ((msgBuffer = malloc(length)) == NULL)
                errorFlag = @"buffer allocation failure";
            else
            {
                // Get system information, store in buffer
                if (sysctl(mgmtInfoBase, 6, msgBuffer, &length, NULL, 0) < 0)
                    errorFlag = @"sysctl msgBuffer failure";
            }
        }
    }
    
    // Befor going any further...
    if (errorFlag != NULL)
    {
        NSLog(@"Error: %@", errorFlag);
        return errorFlag;
    }
    
    // Map msgbuffer to interface message structure
    interfaceMsgStruct = (struct if_msghdr *) msgBuffer;
    
    // Map to link-level socket structure
    socketStruct = (struct sockaddr_dl *) (interfaceMsgStruct + 1);
    
    // Copy link layer address data in socket structure to an array
    memcpy(&macAddress, socketStruct->sdl_data + socketStruct->sdl_nlen, 6);
    
    // Read from char array into a string object, into traditional Mac address format
    NSString *macAddressString = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x",
                                  macAddress[0], macAddress[1], macAddress[2],
                                  macAddress[3], macAddress[4], macAddress[5]];
    
    // Release the buffer memory
    free(msgBuffer);
    
    return macAddressString;
}

+ (NSString *) toUTF8ConvertString:(NSString *)uglyString
{
    // convert blank, etc. charactor to UTF8
    NSMutableString * uglyMutableString = [[NSMutableString alloc] initWithString:uglyString];
    NSRange range = [uglyMutableString rangeOfString:@" "];
    while (!(range.location == NSNotFound && range.length == 0)) {
        [uglyMutableString replaceCharactersInRange:range withString:@"-"];
        range = [uglyMutableString rangeOfString:@" "];
    }
    
    NSString * cleanString = [NSString stringWithString:uglyMutableString];
    return cleanString;
}

+ (void) saveToKeyChainUname:(NSString *)username Pwd:(NSString *)password AppId:(NSString *)appId
{
    NSString *urlSchemeString = [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appId];
    NSString* serviceName = [urlSchemeString stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    [SFHFKeychainUtils storeUsername:kD9KeychainUsername
                         andPassword:username
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
    
    [SFHFKeychainUtils storeUsername:kD9keychainPassword
                         andPassword:password
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
}

//+ (NSArray *) readFromKeyChainAppId:(NSString *)appId
//{
//    NSString *urlSchemeString = [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appId];
//    NSString* serviceName = [urlSchemeString stringByAppendingString:kD9KeychainServiceNameSuffix];
//    
//    NSString *unameString = [SFHFKeychainUtils getPasswordForUsername:kD9KeychainUsername
//                                               andServiceName:serviceName
//                                                        error:nil];
//    
//    NSString *pwdString = [SFHFKeychainUtils getPasswordForUsername:kD9keychainPassword
//                                               andServiceName:serviceName
//                                                        error:nil];
//
//    
//}

+ (NSString *) readUnameFromKeyChainAppId:(NSString *)appId
{
    NSString *urlSchemeString = [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appId];
    NSString* serviceName = [urlSchemeString stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    NSString *unameString = [SFHFKeychainUtils getPasswordForUsername:kD9KeychainUsername
                                                       andServiceName:serviceName
                                                                error:nil];
    return unameString;
}

+ (NSString *) readPwdFromKeyChainAppId:(NSString *)appId
{
    NSString *urlSchemeString = [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appId];
    NSString* serviceName = [urlSchemeString stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    NSString *pwdString = [SFHFKeychainUtils getPasswordForUsername:kD9keychainPassword
                                                     andServiceName:serviceName
                                                              error:nil];
    return pwdString;
}

+ (void) deleteInKeyChainAppId:(NSString *)appId
{
    NSString *urlSchemeString = [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appId];
    NSString* serviceName = [urlSchemeString stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    [SFHFKeychainUtils deleteItemForUsername:kD9KeychainUsername
                              andServiceName:serviceName
                                       error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kD9keychainPassword
                              andServiceName:serviceName
                                       error:nil];
}

@end
