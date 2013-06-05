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
#import "D9SDKUtil.h"
#import "D9Request.h"

#define kD9URLSchemePrefix              @"D9_"
#define kD9KeychainServiceNameSuffix    @"_D9StudioServiceName"
#define kD9KeychainUserID               @"D9UserID"
//#define kD9KeychainPassword             @"D9Password"

@interface D9StudioSDK (Private)

- (NSString *)urlSchemeString;

- (void) saveAuthorizeDataToKeychain;
- (void) readAuthorizeDataFromKeychain;
- (void) deleteAuthorizeDataInKeychain;

- (void) requestWithUsername:(NSString *)username password:(NSString *)password;

@end

@implementation D9StudioSDK

@synthesize appID;
@synthesize appKey;
@synthesize userID;
@synthesize request;
@synthesize delegate;

#pragma mark - D9StudioSDK Life Circle

- (id) initWithAppID:(NSString *)appID andAppKey:(NSString *)appKey {
    if (self = [super init]) {
        self.appID = appID;
        self.appKey = appKey;
        
        [self readAuthorizeDataFromKeychain];
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

- (void) saveAuthorizeDataToKeychain
{
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    [SFHFKeychainUtils storeUsername:kD9KeychainUserID
                         andPassword:userID
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
}

- (void) readAuthorizeDataFromKeychain
{
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    self.userID = [SFHFKeychainUtils getPasswordForUsername:kD9KeychainUserID
                                             andServiceName:serviceName
                                                      error:nil];
}
    
- (void) deleteAuthorizeDataInKeychain
{
    self.userID = nil;
    
    NSString * serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    [SFHFKeychainUtils deleteItemForUsername:kD9KeychainUserID andServiceName:serviceName error:nil];
}

#pragma mark - D9StudioSDK Public Methods

- (void) login
{
    if ([self isLoggedIn])
    {
        // 已经登陆
    }
    // 未登陆，进行登陆操作
    D9LoginDialog *loginView = [[D9LoginDialog alloc] init];
    [loginView setDelegate:self];
    [loginView show:YES];
    [loginView autorelease];
}

- (void) logout
{
    [self deleteAuthorizeDataInKeychain];
    
    if ([delegate respondsToSelector:@selector(d9SDKDidLogOut:)]) {
        [delegate d9SDKDidLogOut:self];
    }
}

- (BOOL) isLoggedIn
{
    return userID;
}



@end
