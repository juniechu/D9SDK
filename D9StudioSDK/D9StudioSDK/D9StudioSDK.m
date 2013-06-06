//
//  D9StudioSDK.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9StudioSDK.h"
#import "D9LoginDialog.h"
#import "SFHFKeychainUtils.h"
#import "D9SDKGlobal.h"
#import "D9Request.h"
#import "D9SDKUtil.h"


#define kD9KeychainUserID               @"D9UserID"

typedef enum {
    kD9LoginScene       = 0,
    kD9RegistScene      = 1,
}kD9Scene;

@interface D9StudioSDK (Private)

- (NSString *)urlSchemeString;

- (void) saveUserIDToKeychain;
- (void) readUserIDFromKeychain;
- (void) deleteUserIDInKeychain;

- (void) requestWithUsername:(NSString *)username password:(NSString *)password;

@end

@implementation D9StudioSDK

@synthesize appID;
@synthesize appKey;
@synthesize userID;
@synthesize request;
@synthesize delegate;

#pragma mark - D9StudioSDK Life Circle

- (id) initWithAppID:(NSString *)theAppID andAppKey:(NSString *)theAppKey {
    if (self = [super init]) {
        self.appID = theAppID;
        self.appKey = theAppKey;
        
        [self readUserIDFromKeychain];
    }
    return self;
}

- (void) dealloc
{
    [appID release], appID = nil;
    [appKey release], appKey = nil;
    
    [userID release], userID = nil;
    
    [request setDelegate:nil];
    [request disconnect];
    [request release], request = nil;
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - D9StudioSDK Private Methods

- (NSString *)urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, appID];
}

- (void) saveUserIDToKeychain
{
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    [SFHFKeychainUtils storeUsername:kD9KeychainUserID
                         andPassword:userID
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
}

- (void) readUserIDFromKeychain
{
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kD9KeychainUserID
                                             andServiceName:serviceName
                                                      error:nil];
}

- (void) deleteUserIDInKeychain
{
    self.userID = nil;
    
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    [SFHFKeychainUtils deleteItemForUsername:kD9KeychainUserID
                              andServiceName:serviceName
                                       error:nil];
}

#pragma mark - D9StudioSDK Public Methods

- (void) login
{
    if ([self isLoggedIn])
    {
        // 已经登陆
        if (DEBUG_LOG) {
            NSLog(@"D9StudioSDK:Is logged in.");
        }
    }
    // 未登陆，进行登陆操作
    D9LoginDialog *loginView = [[D9LoginDialog alloc] init];
    [loginView setDelegate:self];
    [loginView show:YES];
    [loginView autorelease];
}

- (void) logout
{
    [self deleteUserIDInKeychain];
    
    if ([delegate respondsToSelector:@selector(d9SDKDidLogOut:)]) {
        [delegate d9SDKDidLogOut:self];
    }
}

- (BOOL) isLoggedIn
{
    return (userID != nil);
}

#pragma mark - D9LoginDialogDelegate Methods

- (void) loginDialog:(D9LoginDialog *)dialog
        withUsername:(NSString *)username
            password:(NSString *)password
{
    if (DEBUG_LOG) {
        NSLog(@"pass word is:%@, length = %d", password, [password length]);
    }
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username, kD9AccountID,
                            password, kD9Password, nil];
    
    [request disconnect];
    
    self.request = [D9Request requestWithURL:__LOGIN_URL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kD9RequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    [request connect];
    
    sceneType = kD9LoginScene;
}

- (void) registDialog:(D9LoginDialog *)dialog
         withUsername:(NSString *)username
             password:(NSString *)password
{
    NSString *ipAddress = [D9SDKUtil getIPAddress];
    NSString *macAddress = [D9SDKUtil getMacAddress];
    NSString *phoneType = [[UIDevice currentDevice] model];
    NSString *phonePattern = [[UIDevice currentDevice] systemVersion];
    if (DEBUG_LOG) {
        NSLog(@"D9StudioSDK: ip address = %@, mac address = %@", ipAddress, macAddress);
        NSLog(@"D9StudioSDK: phone type = %@, phone pattern = %@", phoneType, phonePattern);
        NSLog(@"pass word is:%@, length = %d", password, [password length]);

    }
    
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username, kD9AccountID,
                            password, kD9Password,
                            @"", kD9RegistMail,
                            __RegistType, kD9RegistType,
                            ipAddress, kD9PhoneIP,
                            macAddress, kD9PhoneMac,
                            phoneType, kD9PhoneType,
                            phonePattern, kD9PhonePattern,
                            nil];
    
    [request disconnect];
    
    self.request = [D9Request requestWithURL:__REGIST_URL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kD9RequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    [request connect];
    
    sceneType = kD9RegistScene;
}

#pragma mark - D9RequestDelegate Methods
- (void) request:(D9Request *)request didFinishLoadingWithResult:(id)result
{
    if (DEBUG_LOG) {
        NSLog(@"didFinishLoadingWithResult:%@", result);
    }
    int resultCode = [(NSString *)result intValue];
    
    if (sceneType == kD9LoginScene) {
        
        //TODO: If success, save username and password, d9SDKDidLogin:(D9StudioSDK *)d9engine;
        if (resultCode == kD9LoginErrorPwd) {
            [D9SDKUtil showAlertViewWithMsg:@"密码错误"];
        } else if (resultCode == kD9LoginErrorNil) {
            [D9SDKUtil showAlertViewWithMsg:@"账户不存在"];
        } else if (resultCode == kD9LoginErrorFail) {
            [D9SDKUtil showAlertViewWithMsg:@"其他错误"];
        } else {
            // success, save user custom setting
            self.userID = result;
            if (DEBUG_LOG) {
                NSLog(@"D9StudioSDK:userID=%@", userID);
            }
            if ([delegate respondsToSelector:@selector(d9SDKDidLogin:)]) {
                [delegate d9SDKDidLogin:self];
            }
        }
    } else if (sceneType == kD9RegistScene) {

        if (resultCode == kD9LoginErrorPwd) {
            [D9SDKUtil showAlertViewWithMsg:@"账号已经存在"];
        } else if (resultCode == kD9LoginErrorNil) {
            [D9SDKUtil showAlertViewWithMsg:@"提交参数有误"];
        } else if (resultCode == kD9LoginErrorFail) {
            [D9SDKUtil showAlertViewWithMsg:@"其他错误"];
        } else {
            // success, save user custom setting
            self.userID = result;
            if (DEBUG_LOG) {
                NSLog(@"D9StudioSDK:userID=%@", userID);
            }
            if ([delegate respondsToSelector:@selector(d9SDKDidLogin:)]) {
                [delegate d9SDKDidLogin:self];
            }
        }
    }
}

- (void) request:(D9Request *)request didFailWithError:(NSError *)error
{
    if (DEBUG_LOG)
    {
        NSLog(@"D9StudioSDK: request difFailWithError.");
    }
    self.userID = nil;
    if ([delegate respondsToSelector:@selector(d9SDK:didFailToLogInWithError:)]) {
        [delegate d9SDK:self didFailToLogInWithError:error];
    }
}

@end
