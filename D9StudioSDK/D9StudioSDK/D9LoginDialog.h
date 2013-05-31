//
//  D9LoginDialog.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface D9LoginDialog : UIView <UITextFieldDelegate> {
    
    UITextField * _usernameTextField;
    UITextField * _passwordTextField;
    UIButton * _rememberPassword;
    UIButton * _autoLogin;
    UILabel * _lblRemember;
    UILabel * _lblAuto;
    
    CGSize winSize;
    
    UIButton * _loginBtn;
    UIButton * _regBtn;
    UIButton * _randomBtn;
    
    UIButton * _toRegBtn;
    UIButton * _toLogBtn;
    
    NSString * _usernameStr;
    NSString * _passwordStr;
    BOOL isRemember;
    BOOL isAuto;
    
}

@end
