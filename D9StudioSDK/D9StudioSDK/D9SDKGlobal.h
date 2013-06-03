//
//  D9SDKGlobal.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-31.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#ifndef D9StudioSDK_D9SDKGlobal_h
#define D9StudioSDK_D9SDKGlobal_h

#define __LOGIN_URL     @"http://imept.imobile-ent.com:8988/D9PayPlat/login.action";
#define __REGIST_URL    @"http://imept.imobile-ent.com:8988/D9PayPlat/register.action";

#define kD9SDKErrorDomain           @"D9SDKErrorDomain"
#define kD9SDKErrorCodeKey          @"D9SDKErrorCodeKey"

//#define kWBSDKAPIDomain             @"https://api.weibo.com/2/"

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

#endif
