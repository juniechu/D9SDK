//
//  D9ChangePwdView.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-8-7.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9ChangePwdView.h"
#import "D9LoginDialog.h"
#import "MobClick.h"
#import "D9SDKGlobal.h"

@interface D9ChangePwdView (Private)
- (void) btnClicked:(UIButton *)sender;
- (void) resignKeyboard;
- (BOOL) isInputValidate;

@end

@implementation D9ChangePwdView
@synthesize userName;
@synthesize oldPassword;
@synthesize nowPassword;
@synthesize comfirmPassword;
@synthesize delegate;

- (id) init {
    self = [super initWithFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
    if (self) {
        //TODO: init change password view here
    }
    return self;
}

- (void) dealloc
{
    SAFE_RELEASE(userName);
    SAFE_RELEASE(oldPassword);
    SAFE_RELEASE(nowPassword);
    SAFE_RELEASE(comfirmPassword);
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark -- Private Method --

- (void) btnClicked:(UIButton *)sender
{
    if (sender == _btnChangePwd) {
        [indicatorView startAnimating];
        
        self.userName = _userNameTextField.text;
        self.oldPassword = _oldPasswordTextField.text;
        self.nowPassword = _newPasswordTextField.text;
        self.comfirmPassword = _comfirmPasswordTextField.text;
        
        if (![self isInputValidate]) {
            [indicatorView stopAnimating];
            return;
        }
        
        if ([delegate respondsToSelector:@selector(dialog:withUserName:changeOldPwd:toNewPwd:)]) {
            [delegate dialog:self withUserName:userName changeOldPwd:oldPassword toNewPwd:nowPassword];
        }
        //TODO: add mobclick event
    } else if (sender == _btnBack) {
        [self removeFromSuperview];
        //TODO: add mobclick event
    }
}

- (void) resignKeyboard
{
    if (_userNameTextField) {
        [_userNameTextField resignFirstResponder];
    }
    if (_oldPasswordTextField) {
        [_oldPasswordTextField resignFirstResponder];
    }
    if (_newPasswordTextField) {
        [_newPasswordTextField resignFirstResponder];
    }
    if (_comfirmPasswordTextField) {
        [_comfirmPasswordTextField resignFirstResponder];
    }
}

- (BOOL) isInputValidate
{
    //TODO: check validation
    return true;
}

#pragma mark -- TextField Delegate --
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    if ( textField == _userNameTextField ) {
        [textField resignFirstResponder];
        [_oldPasswordTextField becomeFirstResponder];
    } else if ( textField == _oldPasswordTextField ) {
        [textField resignFirstResponder];
        [_newPasswordTextField becomeFirstResponder];
    } else if ( textField == _newPasswordTextField ) {
        [textField resignFirstResponder];
        [_comfirmPasswordTextField becomeFirstResponder];
    } else if (textField == _comfirmPasswordTextField) {
        [textField resignFirstResponder];
        [self btnClicked:_btnChangePwd];
    }
    return YES;
}

@end
