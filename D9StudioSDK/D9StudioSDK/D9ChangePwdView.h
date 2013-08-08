//
//  D9ChangePwdView.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-8-7.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@class D9ChangePwdView;

@protocol D9ChangePwdDelegate <NSObject>

- (void) dialog:(D9ChangePwdView *)dialog
   withUserName:(NSString *)username
   changeOldPwd:(NSString *)oldPassword
       toNewPwd:(NSString *)newPassword;

@end

@interface D9ChangePwdView : UIView <UITextFieldDelegate> {
    UITextField* _userNameTextField;
    UITextField* _oldPasswordTextField;
    UITextField* _newPasswordTextField;
    UITextField* _comfirmPasswordTextField;
    
    UIButton*    _btnChangePwd;
    UIButton*    _btnBack;
    
    CGSize winSize;
    UIButton* resignBtn;
    
    NSString* userName;
    NSString* oldPassword;
    NSString* nowPassword;
    NSString* comfirmPassword;
    
    id<D9ChangePwdDelegate> delegate;
    
    UIActivityIndicatorView* indicatorView;
}

@property (nonatomic, retain) NSString* userName;
@property (nonatomic, retain) NSString* oldPassword;
@property (nonatomic, retain) NSString* nowPassword;
@property (nonatomic, retain) NSString* comfirmPassword;
@property (nonatomic, assign) id<D9ChangePwdDelegate> delegate;

- (void) show;
- (void) hide;

@end
