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
#import "D9SDKUtil.h"

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

- (id) initWithUsername:(NSString *)uname {
    self = [super initWithFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
    if (self) {
        //TODO: init change password view here
        self.userName = uname;
        
        CGRect winRect = CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth);
        winSize = winRect.size;
        
        NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"D9Resource" ofType:@"bundle"]];
        
        NSString* bgPath;
        NSString* dirPath;
        
        float fUnameY, fPwdY, fNPwdY, fCPwdY, fChangeBtnY, fBackY;
        float fTxFieldOff, fTxFieldW, fTxFieldH;
        float fFontSize;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            dirPath     = @"ipad";
            fLogoY      = 30.0;
            fUnameY     = 234.0;
            fPwdY       = 280.0;
            fNPwdY      = 326.0;
            fCPwdY      = 372.0;
            fChangeBtnY = 440.0;
            fBackY      = 518.0;
            
            fTxFieldOff = 60.0;
            fTxFieldW   = 350.0;
            fTxFieldH   = 36.0;
            fFontSize   = 18.0;
            bgPath = [bundle pathForResource:@"d9_bg_change_pwd" ofType:@"jpg" inDirectory:dirPath];
        } else {
            dirPath     = @"iphone";
            fLogoY      = 30.0;
            fUnameY     = 100.0;
            fPwdY       = 123.0;
            fNPwdY      = 146.0;
            fCPwdY      = 169.0;
            fChangeBtnY = 203.0;
            fBackY      = 242.0;
            
            fTxFieldOff = 30.0;
            fTxFieldW   = 175.0;
            fTxFieldH   = 18.0;
            fFontSize   = 9.0;
            
            if (DEVICE_IS_IPHONE5) {
                bgPath = [bundle pathForResource:@"d9_bg_change_pwd_5" ofType:@"jpg" inDirectory:dirPath];
            } else {
                bgPath = [bundle pathForResource:@"d9_bg_change_pwd_4" ofType:@"jpg" inDirectory:dirPath];
            }
        }
        
        // 背景
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:bgPath]];
        
        // button to regisn keyboard
        resignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resignBtn setFrame:winRect];
        [resignBtn addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resignBtn];
        
        // Head Logo
        NSString* logoPath = [bundle pathForResource:@"d9_logo" ofType:@"png" inDirectory:dirPath];
        UIImage* logoImage = [UIImage imageWithContentsOfFile:logoPath];
        UIImageView* logoView = [[UIImageView alloc] initWithImage:logoImage];
        [logoView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(logoImage, fLogoY) )];
        [self insertSubview:logoView aboveSubview:resignBtn];
        SAFE_RELEASE(logoView);
        
        // User Name
        NSString* usernamePath = [bundle pathForResource:@"d9_username" ofType:@"png" inDirectory:dirPath];
        UIImage* usernameImage = [UIImage imageWithContentsOfFile:usernamePath];
        UIImageView* usernameImageView = [[UIImageView alloc] initWithImage:usernameImage];
        [usernameImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(usernameImage, fUnameY) )];
        [self insertSubview:usernameImageView aboveSubview:resignBtn];
        
        // User Name TextField
        _userNameTextField = [[UITextField alloc] initWithFrame:CGRectMake( GET_LEFT(usernameImageView) + fTxFieldOff, fUnameY, fTxFieldW, fTxFieldH )];
        [_userNameTextField setBackgroundColor:[UIColor clearColor]];
        [_userNameTextField setTextColor:[UIColor blackColor]];
        [_userNameTextField setDelegate:self];
        [_userNameTextField setPlaceholder:@"用户名："];
        [_userNameTextField setTextAlignment:NSTextAlignmentLeft];
        [_userNameTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_userNameTextField setAdjustsFontSizeToFitWidth:NO];
        [_userNameTextField setBorderStyle:UITextBorderStyleNone];
        [_userNameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_userNameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_userNameTextField setReturnKeyType:UIReturnKeyNext];
        [_userNameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_userNameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [_userNameTextField setText:userName];
        
        [self insertSubview:_userNameTextField aboveSubview:usernameImageView];
        SAFE_RELEASE(usernameImageView);
        
        // Pass Word
        NSString* passwordPath = [bundle pathForResource:@"d9_password" ofType:@"png" inDirectory:dirPath];
        UIImage* passwordImage = [UIImage imageWithContentsOfFile:passwordPath];
        
        UIImageView* oldPasswordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [oldPasswordImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(passwordImage, fPwdY) )];
        [self insertSubview:oldPasswordImageView aboveSubview:resignBtn];
        
        _oldPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake( GET_LEFT(oldPasswordImageView) + fTxFieldOff, fPwdY, fTxFieldW, fTxFieldH )];
        [_oldPasswordTextField setBackgroundColor:[UIColor clearColor]];
        [_oldPasswordTextField setTextColor:[UIColor blackColor]];
        [_oldPasswordTextField setDelegate:self];
        [_oldPasswordTextField setPlaceholder:@"原密码："];
        [_oldPasswordTextField setTextAlignment:NSTextAlignmentLeft];
        [_oldPasswordTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_oldPasswordTextField setAdjustsFontSizeToFitWidth:NO];
        [_oldPasswordTextField setClearsOnBeginEditing:YES];
        [_oldPasswordTextField setBorderStyle:UITextBorderStyleNone];
        [_oldPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_oldPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_oldPasswordTextField setSecureTextEntry:YES];
        [_oldPasswordTextField setReturnKeyType:UIReturnKeyNext];
        
        [self insertSubview:_oldPasswordTextField aboveSubview:oldPasswordImageView];
        SAFE_RELEASE(oldPasswordImageView);
        
        // New Pass Word
        UIImageView* nowPasswordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [nowPasswordImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(passwordImage, fNPwdY) )];
        [self insertSubview:nowPasswordImageView aboveSubview:resignBtn];
        
        _newPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake( GET_LEFT(nowPasswordImageView) + fTxFieldOff, fNPwdY, fTxFieldW, fTxFieldH )];
        [_newPasswordTextField setBackgroundColor:[UIColor clearColor]];
        [_newPasswordTextField setTextColor:[UIColor blackColor]];
        [_newPasswordTextField setDelegate:self];
        [_newPasswordTextField setPlaceholder:@"新密码："];
        [_newPasswordTextField setTextAlignment:NSTextAlignmentLeft];
        [_newPasswordTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_newPasswordTextField setAdjustsFontSizeToFitWidth:NO];
        [_newPasswordTextField setClearsOnBeginEditing:YES];
        [_newPasswordTextField setBorderStyle:UITextBorderStyleNone];
        [_newPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_newPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_newPasswordTextField setSecureTextEntry:YES];
        [_newPasswordTextField setReturnKeyType:UIReturnKeyNext];
        
        [self insertSubview:_newPasswordTextField aboveSubview:nowPasswordImageView];
        SAFE_RELEASE(nowPasswordImageView);

        
        // Comfirm Pass Word
        UIImageView* comfirmPasswordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [comfirmPasswordImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(passwordImage, fCPwdY) )];
        [self insertSubview:comfirmPasswordImageView aboveSubview:resignBtn];
        
        _comfirmPasswordTextField = [[UITextField alloc] initWithFrame:CGRectMake( GET_LEFT(comfirmPasswordImageView) + fTxFieldOff, fCPwdY, fTxFieldW, fTxFieldH )];
        [_comfirmPasswordTextField setBackgroundColor:[UIColor clearColor]];
        [_comfirmPasswordTextField setTextColor:[UIColor blackColor]];
        [_comfirmPasswordTextField setDelegate:self];
        [_comfirmPasswordTextField setPlaceholder:@"确认密码："];
        [_comfirmPasswordTextField setTextAlignment:NSTextAlignmentLeft];
        [_comfirmPasswordTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_comfirmPasswordTextField setAdjustsFontSizeToFitWidth:NO];
        [_comfirmPasswordTextField setClearsOnBeginEditing:YES];
        [_comfirmPasswordTextField setBorderStyle:UITextBorderStyleNone];
        [_comfirmPasswordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_comfirmPasswordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_comfirmPasswordTextField setSecureTextEntry:YES];
        [_comfirmPasswordTextField setReturnKeyType:UIReturnKeyGo];
        
        [self insertSubview:_comfirmPasswordTextField aboveSubview:comfirmPasswordImageView];
        SAFE_RELEASE(comfirmPasswordImageView);
        
        // Change Button
        _btnChangePwd = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnChangePwdPath = [bundle pathForResource:@"d9_button_change" ofType:@"png" inDirectory:dirPath];
        UIImage* btnChangePwdImage = [UIImage imageWithContentsOfFile:btnChangePwdPath];
        NSString* btnChangePwdPressedPath = [bundle pathForResource:@"d9_button_change_pressed" ofType:@"png" inDirectory:dirPath];
        UIImage* btnChangePwdPressedImage = [UIImage imageWithContentsOfFile:btnChangePwdPressedPath];
        
        [_btnChangePwd setFrame:CGRectMake( L_CENTERX_FRAME_RECT(btnChangePwdImage, fChangeBtnY) )];
        [_btnChangePwd setBackgroundImage:btnChangePwdImage forState:UIControlStateNormal];
        [_btnChangePwd setBackgroundImage:btnChangePwdPressedImage forState:UIControlStateSelected];
        
        [_btnChangePwd addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_btnChangePwd aboveSubview:resignBtn];
        
        // Back Button
        _btnBack = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnBackPath = [bundle pathForResource:@"d9_back_login" ofType:@"png" inDirectory:dirPath];
        UIImage* btnBackImage = [UIImage imageWithContentsOfFile:btnBackPath];
        
        [_btnBack setFrame:CGRectMake( L_CENTERX_FRAME_RECT(btnBackImage, fBackY) )];
        [_btnBack setBackgroundImage:btnBackImage forState:UIControlStateNormal];
        [_btnBack addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_btnBack aboveSubview:resignBtn];
    }
    return self;
}

- (void) dealloc
{
    SAFE_RELEASE(userName);
    SAFE_RELEASE(oldPassword);
    SAFE_RELEASE(nowPassword);
    SAFE_RELEASE(comfirmPassword);
    
    SAFE_RELEASE(_userNameTextField);
    SAFE_RELEASE(_oldPasswordTextField);
    SAFE_RELEASE(_newPasswordTextField);
    SAFE_RELEASE(_comfirmPasswordTextField);
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark -- Public Method --

- (void) show {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) {
        window = [[UIApplication sharedApplication].windows objectAtIndex:0];
    }
    [window addSubview:self];
    [window bringSubviewToFront:self];
    if (window.rootViewController.view) {
        [window.rootViewController.view addSubview:self];
        [window.rootViewController.view bringSubviewToFront:self];
    }
}

- (void) hide
{
    [self removeFromSuperview];
}

#pragma mark -- Private Method --

- (void) btnClicked:(UIButton *)sender
{
    if (sender == _btnChangePwd) {
        if (DEBUG_LOG) {
            NSLog(@"change pwd btn clicked!");
        }
        
        [indicatorView startAnimating];
        
        self.userName = _userNameTextField.text;
        self.oldPassword = _oldPasswordTextField.text;
        self.nowPassword = _newPasswordTextField.text;
        self.comfirmPassword = _comfirmPasswordTextField.text;
        
        if (DEBUG_LOG) {
            NSLog(@">> [%@],[%@],[%@],[%@]", userName, oldPassword, nowPassword, comfirmPassword);
        }
        
        if (![self isInputValidate]) {
            [indicatorView stopAnimating];
            return;
        }
        
        NSString* tmpOldString, *tmpNewString;
        if ([oldPassword length] != 32) {
            tmpOldString = [NSString stringWithFormat:@"%@%@", oldPassword, userName];
            tmpOldString = [tmpOldString MD5EncodedString];
        }
        
        if ([nowPassword length] != 32) {
            tmpNewString = [NSString stringWithFormat:@"%@%@", nowPassword, userName];
            tmpNewString = [tmpNewString MD5EncodedString];
        }
        
        if ([delegate respondsToSelector:@selector(dialog:withUserName:changeOldPwd:toNewPwd:)]) {
            [delegate dialog:self withUserName:userName changeOldPwd:tmpOldString toNewPwd:tmpNewString];
        }
        // add mobclick event
        [MobClick event:@"d9BtnChange"];
    } else if (sender == _btnBack) {
        [self removeFromSuperview];
        // add mobclick event
        [MobClick event:@"d9BackFromChange"];
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
    if (!userName || !oldPassword || !nowPassword || !comfirmPassword
        || [userName isEqual:@""] || [oldPassword isEqual:@""] ||
        [nowPassword isEqual:@""] || [comfirmPassword isEqual:@""]) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    
    if (![nowPassword isEqual:comfirmPassword]) {
        [D9SDKUtil showAlertViewWithMsg:@"两次密码输入不一致"];
        return NO;
    }
//    NSLog(@"I Give U YES!");
    return YES;
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

- (void) textFieldDidBeginEditing:(UITextField *)textField
{
    [self setFrame:CGRectMake(0, -fLogoY, winSize.width, winSize.height)];
}

- (void) textFieldDidEndEditing:(UITextField *)textField
{
    [self setFrame:CGRectMake(0, 0, winSize.width, winSize.height)];
}

@end
