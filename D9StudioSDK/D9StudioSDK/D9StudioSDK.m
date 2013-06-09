//
//  D9StudioSDK.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9StudioSDK.h"
#import "D9LoginDialog.h"
#import "D9SDKGlobal.h"
#import "D9Request.h"
#import "D9SDKUtil.h"
#import "D9PayWebView.h"
#import "DataSigner.h"

#define kD9KeychainUserID               @"D9UserID"
#define kD9KeychainAuto                 @"D9AutoLogin"

typedef enum {
    kD9LoginScene       = 0,
    kD9RegistScene      = 1,
}kD9Scene;

@interface D9StudioSDK (Private)

- (void) saveToKeychain;
- (void) readFromKeychain;
- (void) deleteInKeychain;

- (NSString *) generateUniqueOrderId;

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
        
        [self readFromKeychain];
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
    
    [loginView setDelegate:nil];
    [loginView release], loginView = nil;
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - D9StudioSDK Private Methods

- (void) saveToKeychain
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:userID forKey:kD9KeychainUserID];
    
    [userDefault synchronize];
}

- (void) readFromKeychain
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    self.userID = [userDefault stringForKey:kD9KeychainUserID];
}

- (void) deleteInKeychain
{
    self.userID = nil;
    
    [self saveToKeychain];
}

- (NSString *) generateUniqueOrderId
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
    NSString *curTime = [NSString stringWithFormat:@"%llu", dTime];
    
    NSString * clientOrderId = [NSString stringWithFormat:@"%@_%@", curTime, self.userID];
    return clientOrderId;
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
    loginView = [[D9LoginDialog alloc] init];
    [loginView setDelegate:self];
    [loginView show:YES];

}

- (void) logout
{
    [self deleteInKeychain];
    
    if ([delegate respondsToSelector:@selector(d9SDKDidLogOut:)]) {
        [delegate d9SDKDidLogOut:self];
    }
}

- (BOOL) isLoggedIn
{
    return (userID != nil);
}

- (void) enterPayViewWithRoleId:(NSString *)roleID
                     andGoodsId:(NSString *)goodsId
                    andGoodsCnt:(NSString *)goodsCnt
                   andGoodsName:(NSString *)goodsName
                  andTotalMoney:(NSString *)totalMoney
                      andPayDes:(NSString *)payDescription
{
    D9PayWebView *payView = [[[D9PayWebView alloc] init] autorelease];
    NSString *urlString = __PAY_URL;
    NSString *paramString = @"";
    paramString = [paramString stringByAppendingFormat:@"%@=%@", kD9AppID, self.appID];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9UID, self.userID];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9RoleID, roleID];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsID, goodsId];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsCount, goodsCnt];
    // urf-8 encode goods name
    goodsName = [goodsName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsName, goodsName];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9TotalMoney, totalMoney];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9Currency, __PayCurrenty];
    if (payDescription) {
        // pay description is not must.
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayDescription, payDescription];
    }
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9ClientOrderID, [self generateUniqueOrderId]];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneType, [[UIDevice currentDevice] model]];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhonePattern, [[UIDevice currentDevice] systemVersion]];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneMac, [D9SDKUtil getMacAddress]];
    
    if (DEBUG_LOG) {
        NSLog(@"D9StudioSDK: pay Param is:%@", paramString);
        paramString = @"AppId=100001&Uid=10000001&RoleId=2&GoodsId=100001-1&Currency=CNY&TotalMoney=0.01&GoodsCount=1&GoodsName=%E9%92%BB%E7%9F%B3&ClientOrderId=1234567890&PayDescription=1-2-3-test&PayPhoneType=android&PayPhonePattern=5.0&PayPhoneMac=12-34-56-78";
//        paramString = @"AppId=100001&Uid=10000001&RoleId=2&GoodsId=100001-1&Currency=CNY&TotalMoney=0.01&GoodsCount=1&GoodsName=钻石&ClientOrderId=1234567890&PayDescription=1-2-3-test&PayPhoneType=android&PayPhonePattern=5.0&PayPhoneMac=12-34-56-78";
    }
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBANg4Vz5qc/IsOPum4DRV872BThifPtf5Dx2t/CnXf3v0qDc4IjPJwk6zawXWVn7KmTTatyvhw6CoXnJYHyBG74xwgRYD7gCIwpLddSxK0Y6iuiq1vhlEVFOWhpLvRtmNkG92ZiOdEPIpZZEgkurWEfBgdIu0v1nmm2oFsc4i7r0/AgMBAAECgYB2Y4MBnfAWbbhVsi2Y+mcXIDHOsYMLZkesjJNBpckb6f4hHg88JADMbtjuvUlm6y+wDQG2eUtQMGBmY3HHjo+iZ3oCzbqrkiYRKcIj3Sbvrnveu75n3BBwp7VgzRTl06qhkYvtY6VUhlUq+9dbNKuN6htjQniJFqjESmvosUV54QJBAP/jCCbt3siTFEO5fpiFGCShWbc3zecI7BzVIhumLgaa5cEykSQlps7Dv3POcPrOfAcf5/V/gpHWml1whqWyL2MCQQDYUNGCurjYWBtS2osWPd/z9JhS3rtEPMnW2ZZ6J2XsQpPO9YqoCrYyWuzc5EW4Zp8VqVq82pGQvTMOKDO7zSd1AkASEOJbdUHcYV315hvFAuiQdX/TCrKT1DJvWrDcyN/JAZilCj/rEGl1gaZ7s6CQZJGnIx6KW6VJTKB7Zl1rR2hHAkB349sq7Jh0d+i09CFwc1zDlkYyb/Y0rMhlhvVKwLlRx9iqNRbjagRvRkvPZclqmZ4EYHfFAhL5uJMqfoelx9/dAkAx0qffJLCyoOGF/EFD++6RLubofhdRcpwMgaDDj2LXmz8a95PK2/VDrzWlORj7A6Uv1pNY+EFYI2rTB8p5xiT3";
    
//	id<DataSigner> signer = CreateRSADataSigner([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"]);
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
	NSString *signedString = [signer signString:paramString];
    
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9Sign, signedString];
    
    urlString = [urlString stringByAppendingFormat:@"?%@", paramString];
    
    if (DEBUG_LOG) {
        NSLog(@"D9StudioSDK: url string is:%@", urlString);
    }
    NSString *encodedString = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedString];
    [payView loadRequestWithURL:url];
    [payView showPayView:NO];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kD9StopIndicatorNotification
                                                        object:nil];
    
    if (sceneType == kD9LoginScene) {
        
        // If success, save username and password, 
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
            [self saveToKeychain];
            if ([delegate respondsToSelector:@selector(d9SDKDidLogin:)]) {
                [delegate d9SDKDidLogin:self];
            }
            
            [loginView hide:YES];
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
            [self saveToKeychain];
            if ([delegate respondsToSelector:@selector(d9SDKDidLogin:)]) {
                [delegate d9SDKDidLogin:self];
            }
            
            [loginView hide:YES];
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
