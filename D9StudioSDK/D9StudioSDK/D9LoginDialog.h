//
//  D9LoginDialog.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class D9LoginDialog;

@protocol D9LoginDialogDelegate <NSObject>

- (void) loginDialog:(D9LoginDialog *)dialog
          withUsername:(NSString *)username
            password:(NSString *)password;

- (void) registDialog:(D9LoginDialog *)dialog
           withUsername:(NSString *)username
             password:(NSString *)password;

- (void) changePwdDialog:(D9LoginDialog *)dialog
            withUserName:(NSString *)username;

@end

@interface D9LoginDialog : UIView <UITextFieldDelegate> {
    
    UITextField* _usernameTextField;
    UITextField* _passwordTextField;
    UIButton* _rememberPassword;
    UIButton* _autoLogin;
    
    CGSize winSize;
    UIButton* resignBtn;
    
    UIButton* _loginBtn;
    UIButton* _regBtn;
    UIButton* _randomBtn;
    
    UIButton* _toRegBtn;
    UIButton* _toChangePwd;
    UIButton* _toLogBtn;
    
    NSString* _passWord;
    
    BOOL isRemember;
    BOOL isAuto;
    
    UIActivityIndicatorView* indicatorView;
    UIInterfaceOrientation previousOrientation;

}

@property (nonatomic, assign) id<D9LoginDialogDelegate> delegate;
@property (nonatomic, retain) NSString* userName;
//@property (nonatomic, retain) NSString* passWord;
@property (nonatomic, retain) NSString* d9AppID;

- (NSString *)passWord;
- (void) setPassWord:(NSString *)passWord;

- (id) initWithAppID:(NSString *)appID;
- (void) show:(BOOL)animated;
- (void) hide:(BOOL)animated;


@end
