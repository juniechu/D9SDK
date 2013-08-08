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
#define __LOGIN_URL                     @"http://imept.imobile-ent.com:8988/D9PayPlat/login.action"
#define __REGIST_URL                    @"http://imept.imobile-ent.com:8988/D9PayPlat/register.action"
#define __PAY_URL                       @"http://imept.imobile-ent.com:8988/D9PayPlat/order.action"
#define __CHANGE_PWD_URL                @"http://imept.imobile-ent.com:8988/D9PayPlat/changepwd.action"

// 测试环境
//#define __LOGIN_URL                     @"http://paytest.gamed9.com:8080/D9PayPlat/login.action"
//#define __REGIST_URL                    @"http://paytest.gamed9.com:8080/D9PayPlat/register.action"
//#define __PAY_URL                       @"http://paytest.gamed9.com:8080/D9PayPlat/order.action"

#define kD9SDKErrorDomain               @"D9SDKErrorDomain"
#define kD9SDKErrorCodeKey              @"D9SDKErrorCodeKey"


#define DEBUG_LOG       0
#define DEBUG_PAY       0               // test data


#define __RegistType                    @"1"    // 0：手机端快速注册，1：手机端注册，2:web端快速注册，3：web端注册
#define __PayCurrenty                   @"CNY"  // CNY: 人民币

#define kD9AccountID                    @"accountid"
#define kD9Password                     @"password"
#define kD9NewPassword                  @"newpassword"
#define kD9RegistMail                   @"registmail"
#define kD9RegistType                   @"registtype"
#define kD9PhoneIP                      @"ip"
#define kD9PhoneMac                     @"phonemac"
#define kD9PhoneType                    @"phonetype"
#define kD9PhonePattern                 @"phonepattern"
#define kD9AppID                        @"AppId"
#define kD9UID                          @"Uid"
#define kD9RoleID                       @"RoleId"
#define kD9GoodsID                      @"GoodsId"
#define kD9GoodsCount                   @"GoodsCount"
#define kD9GoodsName                    @"GoodsName"
#define kD9TotalMoney                   @"TotalMoney"
#define kD9Currency                     @"Currency"
#define kD9PayDescription               @"PayDescription"
#define kD9ClientOrderID                @"ClientOrderId"
#define kD9PayPhoneType                 @"PayPhoneType"
#define kD9PayPhonePattern              @"PayPhonePattern"
#define kD9PayPhoneMac                  @"PayPhoneMac"
#define kD9Sign                         @"Sign"

#define kD9ScreenHeight                 [[UIScreen mainScreen] bounds].size.height
#define kD9ScreenWidth                  [[UIScreen mainScreen] bounds].size.width

#define kFontTimes                      @"Times New Roman"

#define kD9DefaultAuto                  @"D9Auto"
#define kD9LaunchedBefore               @"D9Launched"

#define kD9StopIndicatorNotification    @"D9StopIndicator"

#define DEVICE_IS_IPHONE5 ([[UIScreen mainScreen] bounds].size.height == 568)

#define SAFE_RELEASE(x) [x release];x=nil

#define GET_WIDTH(obj) obj.size.width
#define GET_HEIGHT(obj) obj.size.height
#define GET_SIZE(obj) GET_WIDTH(obj), GET_HEIGHT(obj)
#define GET_LEFT(obj) obj.frame.origin.x

// Landscape defines
#define L_CENTERX(obj) (kD9ScreenHeight-GET_WIDTH(obj))*0.5
#define L_CENTERX_FRAME_RECT(obj, y) L_CENTERX(obj), y, GET_SIZE(obj)
#define L_OFFSET_LT_FRAME_RECT(obj, offset, y) kD9ScreenHeight*0.5-offset-GET_WIDTH(obj), y, GET_SIZE(obj)
#define L_OFFSET_RT_FRAME_RECT(obj, offset, y) kD9ScreenHeight*0.5+offset, y, GET_SIZE(obj)

// Protraint defines

typedef enum
{
	kD9ErrorCodeInterface	= 100,
	kD9ErrorCodeSDK         = 101,
} D9ErrorCode;

typedef enum
{
	kD9SDKErrorCodeParseError       = 200,
	kD9SDKErrorCodeRequestError     = 201,
	kD9SDKErrorCodeAccessError      = 202,
	kD9SDKErrorCodeAuthorizeError	= 203,
} D9SDKErrorCode;

typedef enum
{
    kD9LoginErrorPwd            = -1,   // 密码错误
    kD9LoginErrorNil            = -2,   // 账号不存在
    kD9LoginErrorFail           = -3,   // 其他错误

} D9LoginErrorCode;

typedef enum {
    kD9RegErrorAlreadyHave      = -1,   // 账号已经存在
    kD9RegErrorParam            = -2,   // 提交参数有误
    kD9RegErrorFail             = -3,   // 其他错误
    
} D9RegErrorCode;

typedef enum
{
    kD9ChangePwdErrorPwd        = -1,   // 密码错误
    kD9ChangePwdErrorNil        = -2,   // 账号不存在
    kD9ChangePwdErrorFail       = -3,   // 修改密码失败
    kD9ChangePwdErrorNet        = -4,   // 网络错误，请重试
} D9ChangePwdErrorCode;

#endif
