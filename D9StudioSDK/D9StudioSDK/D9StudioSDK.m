//
//  D9StudioSDK.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9StudioSDK.h"
#import "D9SDKGlobal.h"
#import "D9Request.h"
#import "D9LoginDialog.h"
#import "D9SDKUtil.h"
#import "D9PayWebView.h"
#import "DataSigner.h"
#import "MobClick.h"
#import "D9ChangePwdView.h"

#define kD9KeychainUserID               @"D9UserID"

typedef enum {
    kD9LoginScene       = 0,
    kD9RegistScene      = 1,
    kD9ChangeScene      = 2,
}kD9Scene;

@interface D9StudioSDK (Private) <D9LoginDialogDelegate, D9RequestDelegate, D9ChangePwdDelegate>

@property (nonatomic, retain) D9Request *request;

- (void) saveToKeychain;
- (void) readFromKeychain;
- (void) deleteInKeychain;

- (void) deleteLoginData;

- (NSString *) generateUniqueOrderId;

- (NSString *) getRSASignithRoleId:(NSString *)roleID
                        andGoodsId:(NSString *)goodsId
                       andGoodsCnt:(NSString *)goodsCnt
                      andGoodsName:(NSString *)goodsName
                     andTotalMoney:(NSString *)totalMoney
                         andPayDes:(NSString *)payDescription;
- (void) sendStatistics;

@end

@implementation D9StudioSDK

@synthesize appID;
@synthesize appKey;
@synthesize userID;
@synthesize nowPwd;
@synthesize request;
@synthesize delegate;

#pragma mark - D9StudioSDK Life Circle

- (id) initWithAppID:(NSString *)theAppID andAppKey:(NSString *)theAppKey {
    if (self = [super init]) {
        [MobClick startWithAppkey:@"51ff1d4b56240b47680fa823" reportPolicy:REALTIME channelId:nil];
        
        self.appID = theAppID;
        self.appKey = theAppKey;
        
        [self readFromKeychain];
        
        if (!isLaunched) {
            isLaunched = YES;
            
            [self sendStatistics];
        }
    }
    return self;
}

- (void) dealloc
{
//    [appID release], appID = nil;
//    [appKey release], appKey = nil;
    SAFE_RELEASE(appID);
    SAFE_RELEASE(appKey);
    
//    [userID release], userID = nil;
    SAFE_RELEASE(userID);
    
    [request setDelegate:nil];
    [request disconnect];
//    [request release], request = nil;
    SAFE_RELEASE(request);
    
    [loginView setDelegate:nil];
//    [loginView release], loginView = nil;
    SAFE_RELEASE(loginView);
    
    [changeView setDelegate:nil];
    SAFE_RELEASE(changeView);
    SAFE_RELEASE(nowPwd);
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark - D9StudioSDK Private Methods

- (void) sendStatistics
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* launchedKey = [NSString stringWithFormat:@"%@%@", kD9LaunchedBefore, appID];
    [userDefault setBool:isLaunched forKey:launchedKey];
    [userDefault synchronize];
    
    //TODO: send current machine info to server.
//    NSString *lowerMacAddress = [D9SDKUtil getLowerMacAddress];
//    NSString *deviceString = @"iOS";
//    NSString *phoneType = [[UIDevice currentDevice] model];
//    NSString *phonePattern = [[UIDevice currentDevice] systemVersion];
    
    
}

- (void) saveToKeychain
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* uIDKey = [NSString stringWithFormat:@"%@%@", kD9KeychainUserID, appID];
    [userDefault setObject:userID forKey:uIDKey];
    
    NSString* launchedKey = [NSString stringWithFormat:@"%@%@", kD9LaunchedBefore, appID];
    [userDefault setBool:isLaunched forKey:launchedKey];
    
    [userDefault synchronize];
}

- (void) readFromKeychain
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* uIDKey = [NSString stringWithFormat:@"%@%@", kD9KeychainUserID, appID];
    self.userID = [userDefault stringForKey:uIDKey];
    
    NSString* launchedKey = [NSString stringWithFormat:@"%@%@", kD9LaunchedBefore, appID];
    isLaunched = [userDefault boolForKey:launchedKey];
}

- (void) deleteInKeychain
{
    self.userID = nil;
    
    [self saveToKeychain];
}

- (void) deleteLoginData
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    NSString* autoKey = [NSString stringWithFormat:@"%@%@", kD9DefaultAuto, appID];
    [userDefault setBool:false forKey:autoKey];
    
    [userDefault synchronize];
}

- (NSString *) generateUniqueOrderId
{
    NSTimeInterval time = [[NSDate date] timeIntervalSince1970];
    long long dTime = [[NSNumber numberWithDouble:time] longLongValue];
    NSString *curTime = [NSString stringWithFormat:@"%llu", dTime];
    
    NSString * clientOrderId = [NSString stringWithFormat:@"%@-%@", curTime, userID];
    return clientOrderId;
}

- (NSString *) getRSASignithRoleId:(NSString *)roleID
                        andGoodsId:(NSString *)goodsId
                       andGoodsCnt:(NSString *)goodsCnt
                      andGoodsName:(NSString *)goodsName
                     andTotalMoney:(NSString *)totalMoney
                         andPayDes:(NSString *)payDescription
{
    NSString *paramString = @"";
    paramString = [paramString stringByAppendingFormat:@"%@=%@", kD9AppID, appID];
    if (DEBUG_PAY) {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9ClientOrderID, @"1374217427-10016161"];
    } else {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9ClientOrderID, [self generateUniqueOrderId]];
    }
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9Currency, __PayCurrenty];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsCount, goodsCnt];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsID, goodsId];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsName, goodsName];
    if (payDescription && ![payDescription isEqual:@""]) {
        // pay description is not necessary.
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayDescription, payDescription];
    }
    if (DEBUG_PAY) {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneMac, @"34-15-9E-7C-D8-70"];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhonePattern, @"5.1.1"];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneType, @"iPod-touch"];
    } else {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneMac, [D9SDKUtil getMacAddress]];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhonePattern, [[UIDevice currentDevice] systemVersion]];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneType, [[UIDevice currentDevice] model]];
    }

    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9RoleID, roleID];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9TotalMoney, totalMoney];
    if (DEBUG_PAY) {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9UID, @"10016161"];
    } else {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9UID, userID];
    }
    
    if (DEBUG_PAY) {
//        paramString = @"AppId=100001&ClientOrderId=1234567890&Currency=CNY&GoodsCount=1&GoodsId=100001-1&GoodsName=钻石&PayDescription=1-2-3-test&PayPhoneMac=12-34-56-78&PayPhonePattern=5.0&PayPhoneType=android&RoleId=2&TotalMoney=0.01&Uid=10000001";

        NSLog(@"Param String is:%@", paramString);
    }
    paramString = [D9SDKUtil toUTF8ConvertString:paramString];
    
    //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
    NSString *privateKey = @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBANg4Vz5qc/IsOPum4DRV872BThifPtf5Dx2t/CnXf3v0qDc4IjPJwk6zawXWVn7KmTTatyvhw6CoXnJYHyBG74xwgRYD7gCIwpLddSxK0Y6iuiq1vhlEVFOWhpLvRtmNkG92ZiOdEPIpZZEgkurWEfBgdIu0v1nmm2oFsc4i7r0/AgMBAAECgYB2Y4MBnfAWbbhVsi2Y+mcXIDHOsYMLZkesjJNBpckb6f4hHg88JADMbtjuvUlm6y+wDQG2eUtQMGBmY3HHjo+iZ3oCzbqrkiYRKcIj3Sbvrnveu75n3BBwp7VgzRTl06qhkYvtY6VUhlUq+9dbNKuN6htjQniJFqjESmvosUV54QJBAP/jCCbt3siTFEO5fpiFGCShWbc3zecI7BzVIhumLgaa5cEykSQlps7Dv3POcPrOfAcf5/V/gpHWml1whqWyL2MCQQDYUNGCurjYWBtS2osWPd/z9JhS3rtEPMnW2ZZ6J2XsQpPO9YqoCrYyWuzc5EW4Zp8VqVq82pGQvTMOKDO7zSd1AkASEOJbdUHcYV315hvFAuiQdX/TCrKT1DJvWrDcyN/JAZilCj/rEGl1gaZ7s6CQZJGnIx6KW6VJTKB7Zl1rR2hHAkB349sq7Jh0d+i09CFwc1zDlkYyb/Y0rMhlhvVKwLlRx9iqNRbjagRvRkvPZclqmZ4EYHfFAhL5uJMqfoelx9/dAkAx0qffJLCyoOGF/EFD++6RLubofhdRcpwMgaDDj2LXmz8a95PK2/VDrzWlORj7A6Uv1pNY+EFYI2rTB8p5xiT3";
    
    //	id<DataSigner> signer = CreateRSADataSigner([[NSBundle mainBundle] objectForInfoDictionaryKey:@"RSA private key"]);
//    id<DataSigner> signer = CreateRSADataSigner(self.appKey);
    id<DataSigner> signer = CreateRSADataSigner(privateKey);
	NSString *signedString = [signer signString:paramString];
    
    return signedString;
//    return NULL;
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
    [MobClick event:@"d9LoginMethod"];
    
    loginView = [[D9LoginDialog alloc] initWithAppID:appID];
    [loginView setDelegate:self];
    [loginView show:YES];

}

- (void) logout
{
    [self deleteInKeychain];

    [self deleteLoginData];
    
    [MobClick event:@"d9LogoutMethod"];
    
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
    NSString *signString = [self getRSASignithRoleId:roleID andGoodsId:goodsId andGoodsCnt:goodsCnt andGoodsName:goodsName andTotalMoney:totalMoney andPayDes:payDescription];
    
    D9PayWebView *payView = [[[D9PayWebView alloc] init] autorelease];
    NSString *urlString = __PAY_URL;
    NSString *paramString = @"";
    paramString = [paramString stringByAppendingFormat:@"%@=%@", kD9AppID, appID];
    if (DEBUG_PAY) {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9UID, @"10016161"];
    } else {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9UID, userID];
    }
    
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9RoleID, roleID];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsID, goodsId];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsCount, goodsCnt];
    // urf-8 encode goods name
    goodsName = [goodsName stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9GoodsName, goodsName];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9TotalMoney, totalMoney];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9Currency, __PayCurrenty];
    if (payDescription && ![payDescription isEqual:@""]) {
        // pay description is not necessary.
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayDescription, payDescription];
    }
    
    if (DEBUG_PAY) {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9ClientOrderID, @"1374217427-10016161"];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneType, @"iPod-touch"];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhonePattern, @"5.1.1"];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneMac, @"34-15-9E-7C-D8-70"];
    } else {
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9ClientOrderID, [self generateUniqueOrderId]];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneType, [[UIDevice currentDevice] model]];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhonePattern, [[UIDevice currentDevice] systemVersion]];
        paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9PayPhoneMac, [D9SDKUtil getMacAddress]];
    }
    
    paramString = [D9SDKUtil toUTF8ConvertString:paramString];
    paramString = [paramString stringByAppendingFormat:@"&%@=%@", kD9Sign, signString];
    urlString = [urlString stringByAppendingFormat:@"?%@", paramString];
    
//    if (DEBUG_LOG) {
        NSLog(@"D9StudioSDK: PayUrlString:\n%@", urlString);
//    }
    NSURL *url = [NSURL URLWithString:urlString];

    [MobClick event:@"d9PayMethod"];
    
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
        NSLog(@"D9StudioSDK: username = [%@], password = [%@]", username, password);
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

- (void) changePwdDialog:(D9LoginDialog *)dialog withUserName:(NSString *)username
{
    changeView = [[D9ChangePwdView alloc] initWithUsername:username];
    [changeView setDelegate:self];
    [changeView show];
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
            [MobClick event:@"d9LoginError" label:@"ErrorPwd"];
            [D9SDKUtil showAlertViewWithMsg:@"密码错误"];
        } else if (resultCode == kD9LoginErrorNil) {
            [MobClick event:@"d9LoginError" label:@"ErrorNil"];
            [D9SDKUtil showAlertViewWithMsg:@"账户不存在"];
        } else if (resultCode == kD9LoginErrorFail) {
            [MobClick event:@"d9LoginError" label:@"ErrorFail"];
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
            [MobClick event:@"d9RegError" label:@"ErrorPwd"];
            [D9SDKUtil showAlertViewWithMsg:@"账号已经存在"];
        } else if (resultCode == kD9LoginErrorNil) {
            [MobClick event:@"d9RegError" label:@"ErrorNil"];
            [D9SDKUtil showAlertViewWithMsg:@"提交参数有误"];
        } else if (resultCode == kD9LoginErrorFail) {
            [MobClick event:@"d9RegError" label:@"ErrorFail"];
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
    } else if (sceneType == kD9ChangeScene) {
        if (resultCode == kD9ChangePwdErrorPwd) {
            [MobClick event:@"d9ChangeError" label:@"ErrorPwd"];
            [D9SDKUtil showAlertViewWithMsg:@"密码错误"];
        } else if (resultCode == kD9ChangePwdErrorNil) {
            [MobClick event:@"d9ChangeError" label:@"ErrorNil"];
            [D9SDKUtil showAlertViewWithMsg:@"帐号不存在"];
        } else if (resultCode == kD9ChangePwdErrorFail) {
            [MobClick event:@"d9ChangeError" label:@"ErrorFail"];
            [D9SDKUtil showAlertViewWithMsg:@"修改密码失败"];
        } else if (resultCode == kD9ChangePwdErrorNet) {
            [MobClick event:@"d9ChangeError" label:@"ErrorNet"];
            [D9SDKUtil showAlertViewWithMsg:@"网络错误，请重试"];
        } else {
            // 修改密码成功，转到登陆界面
            [D9SDKUtil showSuccessAlertViewWithMsg:@"修改密码成功"];
            if (changeView) {
                [changeView hide];
            }
            
            // bugfix: update the password!
            [loginView setPassWord:nowPwd];
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

#pragma mark -- D9 Change Password Delegate --
- (void) dialog:(D9ChangePwdView *)dialog
   withUserName:(NSString *)username
   changeOldPwd:(NSString *)oldPassword
       toNewPwd:(NSString *)newPassword
{
    if (DEBUG_LOG) {
        NSLog(@"old pass word is:%@, length = %d", oldPassword, [oldPassword length]);
        NSLog(@"new pass word is:%@, length = %d", newPassword, [newPassword length]);
    }
    
    self.nowPwd = newPassword;
    
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:username, kD9AccountID,
                            oldPassword, kD9Password, newPassword, kD9NewPassword, nil];
    [request disconnect];
    
    self.request = [D9Request requestWithURL:__CHANGE_PWD_URL
                                  httpMethod:@"POST"
                                      params:params
                                postDataType:kD9RequestPostDataTypeNormal
                            httpHeaderFields:nil
                                    delegate:self];
    [request connect];
    
    sceneType = kD9ChangeScene;
}

@end
