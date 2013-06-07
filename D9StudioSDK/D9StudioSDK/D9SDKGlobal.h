//
//  D9SDKGlobal.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-31.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#ifndef D9StudioSDK_D9SDKGlobal_h
#define D9StudioSDK_D9SDKGlobal_h

// 正式环境
//#define __LOGIN_URL                     @"http://imept.imobile-ent.com:8988/D9PayPlat/login.action"
//#define __REGIST_URL                    @"http://imept.imobile-ent.com:8988/D9PayPlat/register.action"

// 测试环境
#define __LOGIN_URL                     @"http://paytest.gamed9.com:8080/D9PayPlat/login.action"
#define __REGIST_URL                    @"http://paytest.gamed9.com:8080/D9PayPlat/register.action"

#define kD9SDKErrorDomain               @"D9SDKErrorDomain"
#define kD9SDKErrorCodeKey              @"D9SDKErrorCodeKey"

//#define kD9URLSchemePrefix              @"D9_"
//#define kD9KeychainServiceNameSuffix    @"_D9StudioServiceName"

#define DEBUG_LOG       1

#define __RegistType                    @"1"    //0：手机端快速注册，1：手机端注册，2:web端快速注册，3：web端注册

#define kD9AccountID                    @"accountid"
#define kD9Password                     @"password"
#define kD9RegistMail                   @"registmail"
#define kD9RegistType                   @"registtype"
#define kD9PhoneIP                      @"ip"
#define kD9PhoneMac                     @"phonemac"
#define kD9PhoneType                    @"phonetype"
#define kD9PhonePattern                 @"phonepattern"

#define kD9StopIndicatorNotification    @"D9StopIndicator"

typedef enum
{
	kD9ErrorCodeInterface	= 100,
	kD9ErrorCodeSDK         = 101,
}D9ErrorCode;

typedef enum
{
	kD9SDKErrorCodeParseError       = 200,
	kD9SDKErrorCodeRequestError     = 201,
	kD9SDKErrorCodeAccessError      = 202,
	kD9SDKErrorCodeAuthorizeError	= 203,
}D9SDKErrorCode;

typedef enum
{
    kD9LoginErrorPwd            = -1,   // 密码错误
    kD9LoginErrorNil            = -2,   // 账号不存在
    kD9LoginErrorFail           = -3,   // 其他错误

}D9LoginErrorCode;

typedef enum {
    kD9RegErrorAlreadyHave      = -1,   // 账号已经存在
    kD9RegErrorParam            = -2,   // 提交参数有误
    kD9RegErrorFail             = -3,   // 其他错误
    
}D9RegErrorCode;

#endif
