//
//  D9LoginDialog.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9LoginDialog.h"
#import "D9SDKUtil.h"
#import "D9SDKGlobal.h"

#import "MobClick.h"

#define kD9DefaultRemember      @"D9Remember"


@interface D9LoginDialog (Private)
- (void) checkboxClicked:(UIButton *)btn;
- (void) resignKeyboard;
- (void) btnClicked:(UIButton *)sender;
- (BOOL) isInputValid;
// For Android users whose username less than 6
- (BOOL) isLoginInputValid;

- (void) saveSettingToDefault;
- (void) readSettingFromDefault;
- (void) deleteSettingInDefault;

- (void) stopIndicatorAnimat;

- (void) addObservers;
- (void) removeObservers;
@end

@implementation D9LoginDialog

@synthesize delegate;
@synthesize userName;
//@synthesize passWord;
@synthesize d9AppID;

- (id)initWithAppID:(NSString *)appID
{
    self = [super initWithFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
    if (DEBUG_LOG) {
        NSLog(@"First:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        NSLog(@"D9LoginDialog init, changed?");
    }
    if (self) {
        // Initialization code
        self.d9AppID = appID;
        
        _passWord = [[NSString alloc] init];
        
        CGRect winRect = CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth);
        winSize = winRect.size;
        if (DEBUG_LOG) {
            NSLog(@"Second:width:[%f], height[%f]", winSize.width, winSize.height);
            NSLog(@"Current Mode: width:[%f], height[%f]", [[UIScreen mainScreen] currentMode].size.width, [[UIScreen mainScreen] currentMode].size.height);
        }
        
        [self readSettingFromDefault];
        isRemember = true;
        
        NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"D9Resource" ofType:@"bundle"]];
        
        NSString* bgPath;
        
        NSString* dirPath;
        float fLogoY, fUnameY, fPwdY, fRemAutoY, fLoginY, fToRegY, fRegRandomY, fToLoginY;
        float fRemAutoOff, fRegRandomOff;
        float fTxFieldOff, fTxFieldW, fTxFieldH;
        float fFontSize;
        
        float fChangePwdOff;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            dirPath     = @"ipad";
            fLogoY      = 30.0;
            fUnameY     = 274.0;
            fPwdY       = 321.0;
            fRemAutoY   = 378.0;
            fRemAutoOff = 30.0;
            fLoginY     = 419.0;
            fToRegY     = 473.0;
            fRegRandomY = 392.0;
            fRegRandomOff = 14.0;
            fToLoginY   = 454.0;
            fTxFieldOff = 60.0;
            fTxFieldW   = 350.0;
            fTxFieldH   = 36.0;
            fFontSize   = 18.0;
            fChangePwdOff = 106.0;
            bgPath = [bundle pathForResource:@"d9_background" ofType:@"jpg" inDirectory:dirPath];
        } else {
            dirPath     = @"iphone";
            fLogoY      = 24.0;
            fUnameY     = 90.0;
            fPwdY       = 125.0;
            fRemAutoY   = 165.0;
            fRemAutoOff = 32.0;
            fLoginY     = 200.0;
            fToRegY     = 250.0;
            fRegRandomY = 190.0;
            fRegRandomOff = 12.0;
            fToLoginY   = 250.0;
            fTxFieldOff = 43.0;
            fTxFieldW   = 264.0;
            fTxFieldH   = 26.0;
            fFontSize   = 11.0;
            fChangePwdOff = 45.0;
            if (DEVICE_IS_IPHONE5) {
                bgPath = [bundle pathForResource:@"d9_background_5" ofType:@"jpg" inDirectory:dirPath];
            } else {
                bgPath = [bundle pathForResource:@"d9_background_4" ofType:@"jpg" inDirectory:dirPath];
            }
        }
        
        
        
        // 背景
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:bgPath]];
        
        // button to resign keyborad
        resignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resignBtn setFrame:winRect];
        [resignBtn addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resignBtn];
        
        
        // Head Logo
        
        NSString* logoPath = [bundle pathForResource:@"d9_logo" ofType:@"png" inDirectory:dirPath];
        UIImage* logoImage = [UIImage imageWithContentsOfFile:logoPath];
        if (!logoImage) {
            NSLog(@"ERROR: D9StudioSDK >> [Resource not found! Please add Resource into your project.]");
        }
        UIImageView* logoView = [[UIImageView alloc] initWithImage:logoImage];
        [logoView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(logoImage, fLogoY) )];
        [self insertSubview:logoView belowSubview:resignBtn];
        SAFE_RELEASE(logoView);
        
        // User Name
        NSString* usernamePath = [bundle pathForResource:@"d9_username" ofType:@"png" inDirectory:dirPath];
        UIImage* usernameImg = [UIImage imageWithContentsOfFile:usernamePath];
        
        UIImageView* usernameImageView = [[UIImageView alloc] initWithImage:usernameImg];
        [usernameImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(usernameImg, fUnameY) )];
        [self insertSubview:usernameImageView aboveSubview:resignBtn];
        
        // landscape
        
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(GET_LEFT(usernameImageView) + fTxFieldOff, fUnameY, fTxFieldW, fTxFieldH )];
        [_usernameTextField setBackgroundColor:[UIColor clearColor]];
        [_usernameTextField setTextColor:[UIColor blackColor]];
        [_usernameTextField setDelegate:self];
        //TODO: use NSLocalizedString() instead
        [_usernameTextField setPlaceholder:@"用户名："];
        [_usernameTextField setTextAlignment:NSTextAlignmentLeft];
        [_usernameTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_usernameTextField setAdjustsFontSizeToFitWidth:NO];
        [_usernameTextField setBorderStyle:UITextBorderStyleNone];
        [_usernameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_usernameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_usernameTextField setReturnKeyType:UIReturnKeyNext];
        [_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [self insertSubview:_usernameTextField aboveSubview:usernameImageView];
        
        SAFE_RELEASE(usernameImageView);
        
        if (userName) {
            [_usernameTextField setText:userName];
        }
        
        // Pass Word
        NSString* passwordPath = [bundle pathForResource:@"d9_password" ofType:@"png" inDirectory:dirPath];
        UIImage* passwordImage = [UIImage imageWithContentsOfFile:passwordPath];
        UIImageView * passwordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [passwordImageView setFrame:CGRectMake( L_CENTERX_FRAME_RECT(passwordImage, fPwdY) )];
        [self insertSubview:passwordImageView aboveSubview:resignBtn];
        
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(GET_LEFT(passwordImageView) + fTxFieldOff, fPwdY, fTxFieldW, fTxFieldH)];
        [_passwordTextField setBackgroundColor:[UIColor clearColor]];
        [_passwordTextField setTextColor:[UIColor blackColor]];
        [_passwordTextField setDelegate:self];
        [_passwordTextField setPlaceholder:@"密码："];
        [_passwordTextField setTextAlignment:NSTextAlignmentLeft];
        [_passwordTextField setFont:[UIFont fontWithName:kFontTimes size:fFontSize]];
        [_passwordTextField setAdjustsFontSizeToFitWidth:NO];
        [_passwordTextField setClearsOnBeginEditing:YES];
        [_passwordTextField setBorderStyle:UITextBorderStyleNone];
        [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_passwordTextField setSecureTextEntry:YES];
        [_passwordTextField setReturnKeyType:UIReturnKeyGo];
        
        [self insertSubview:_passwordTextField aboveSubview:passwordImageView];
        SAFE_RELEASE(passwordImageView);
        
        if (isRemember && _passWord && ![_passWord isEqual:@""]) {
//            NSLog(@"password not nil:%@", _passWord);
            [_passwordTextField setText:_passWord];
        }
        
        // Remember Password
        _rememberPassword = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSString* rememberFalsePath = [bundle pathForResource:@"d9_remember_false" ofType:@"png" inDirectory:dirPath];
        UIImage* rememberFalseImage = [UIImage imageWithContentsOfFile:rememberFalsePath];
        NSString* rememberTruePath = [bundle pathForResource:@"d9_remember_true" ofType:@"png" inDirectory:dirPath];
        UIImage* rememberTrueImage = [UIImage imageWithContentsOfFile:rememberTruePath];
        
        CGRect rememberCheckboxRect = CGRectMake( L_OFFSET_LT_FRAME_RECT(rememberFalseImage, fRemAutoOff, fRemAutoY) );
        [_rememberPassword setFrame:rememberCheckboxRect];
        [_rememberPassword setImage:rememberFalseImage forState:UIControlStateNormal];
        [_rememberPassword setImage:rememberTrueImage forState:UIControlStateSelected];
        
        [_rememberPassword addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_rememberPassword aboveSubview:resignBtn];
        
        if (isRemember) {
            [_rememberPassword setSelected:YES];
        }
        
        
        // Auto Login
        _autoLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSString* autologinFalsePath = [bundle pathForResource:@"d9_autologin_false" ofType:@"png" inDirectory:dirPath];
        UIImage* autologinFalseImage = [UIImage imageWithContentsOfFile:autologinFalsePath];
        NSString* autologinTruePath = [bundle pathForResource:@"d9_autologin_true" ofType:@"png" inDirectory:dirPath];
        UIImage* autologinTrueImage = [UIImage imageWithContentsOfFile:autologinTruePath];
        
        CGRect autoCheckboxRect = CGRectMake( L_OFFSET_RT_FRAME_RECT(autologinFalseImage, fRemAutoOff, fRemAutoY) );
        [_autoLogin setFrame:autoCheckboxRect];
        [_autoLogin setImage:autologinFalseImage forState:UIControlStateNormal];
        [_autoLogin setImage:autologinTrueImage forState:UIControlStateSelected];
        
        [_autoLogin addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_autoLogin aboveSubview:resignBtn];
        
        if (isAuto) {
            [_autoLogin setSelected:YES];
        } else {
            [_autoLogin setSelected:NO];
        }
        
        // Login Button
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        
        NSString* btnLoginNormalPath = [bundle pathForResource:@"d9_button_login" ofType:@"png" inDirectory:dirPath];
        UIImage* btnLoginNormalImage = [UIImage imageWithContentsOfFile:btnLoginNormalPath];
        NSString* btnLoginPressedPath = [bundle pathForResource:@"d9_button_login_pressed" ofType:@"png" inDirectory:dirPath];
        UIImage* btnLoginPressedImage = [UIImage imageWithContentsOfFile:btnLoginPressedPath];
        
        [_loginBtn setFrame:CGRectMake( L_CENTERX_FRAME_RECT(btnLoginNormalImage, fLoginY) )];
        [_loginBtn setBackgroundImage:btnLoginNormalImage forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:btnLoginPressedImage forState:UIControlStateSelected];
        
        [_loginBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_loginBtn aboveSubview:resignBtn];
        
        
        // To Register Button
        _toRegBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnRegistHerePath = [bundle pathForResource:@"d9_regist_here" ofType:@"png" inDirectory:dirPath];
        UIImage* btnRegistHereImage = [UIImage imageWithContentsOfFile:btnRegistHerePath];
        
//        [_toRegBtn setFrame:CGRectMake( L_CENTERX_FRAME_RECT(btnRegistHereImage, fToRegY) )];
        [_toRegBtn setFrame:CGRectMake( L_OFFSET_LT_FRAME_RECT(btnRegistHereImage, fChangePwdOff, fToRegY) )];
        [_toRegBtn setBackgroundImage:btnRegistHereImage forState:UIControlStateNormal];
        [_toRegBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_toRegBtn aboveSubview:resignBtn];
        
        
        // Change Password Button
        _toChangePwd = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnChangePwdPath = [bundle pathForResource:@"d9_change_pwd" ofType:@"png" inDirectory:dirPath];
        UIImage* btnChangePwdImage = [UIImage imageWithContentsOfFile:btnChangePwdPath];

        [_toChangePwd setFrame:CGRectMake( L_OFFSET_RT_FRAME_RECT(btnChangePwdImage, fChangePwdOff, fToRegY) )];
        [_toChangePwd setBackgroundImage:btnChangePwdImage forState:UIControlStateNormal];
        [_toChangePwd addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_toChangePwd aboveSubview:resignBtn];
        
        // Register Button
        _regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnRegistPath = [bundle pathForResource:@"d9_button_regist" ofType:@"png" inDirectory:dirPath];
        UIImage* btnRegistImage = [UIImage imageWithContentsOfFile:btnRegistPath];
        NSString* btnRegistPressedPath = [bundle pathForResource:@"d9_button_regist_pressed" ofType:@"png" inDirectory:dirPath];
        UIImage* btnRegistPressedImage = [UIImage imageWithContentsOfFile:btnRegistPressedPath];
        
        [_regBtn setFrame:CGRectMake( L_OFFSET_LT_FRAME_RECT(btnRegistImage, fRegRandomOff, fRegRandomY) )];
        [_regBtn setBackgroundImage:btnRegistImage forState:UIControlStateNormal];
        [_regBtn setBackgroundImage:btnRegistPressedImage forState:UIControlStateSelected];
        [_regBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_regBtn aboveSubview:resignBtn];
        [_regBtn setHidden:YES];
        
        
        // Random Button
        _randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnRandomPath = [bundle pathForResource:@"d9_button_random" ofType:@"png" inDirectory:dirPath];
        UIImage* btnRandomImage = [UIImage imageWithContentsOfFile:btnRandomPath];
        NSString* btnRandomPressedPath = [bundle pathForResource:@"d9_button_random_pressed" ofType:@"png" inDirectory:dirPath];
        UIImage* btnRandomPressedImage = [UIImage imageWithContentsOfFile:btnRandomPressedPath];
        
        [_randomBtn setFrame:CGRectMake( L_OFFSET_RT_FRAME_RECT(btnRandomImage, fRegRandomOff, fRegRandomY) )];
        [_randomBtn setBackgroundImage:btnRandomImage forState:UIControlStateNormal];
        [_randomBtn setBackgroundImage:btnRandomPressedImage forState:UIControlStateSelected];
        [_randomBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_randomBtn aboveSubview:resignBtn];
        [_randomBtn setHidden:YES];
        
        // To Login Button
        _toLogBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        NSString* btnToLoginPath = [bundle pathForResource:@"d9_login_here" ofType:@"png" inDirectory:dirPath];
        UIImage* btnToLoginImage = [UIImage imageWithContentsOfFile:btnToLoginPath];
        
        [_toLogBtn setFrame:CGRectMake( L_CENTERX_FRAME_RECT(btnToLoginImage, fToLoginY) )];
        [_toLogBtn setBackgroundImage:btnToLoginImage forState:UIControlStateNormal];
        [_toLogBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_toLogBtn aboveSubview:resignBtn];
        [_toLogBtn setHidden:YES];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        
        [indicatorView setCenter:CGPointMake(winSize.width * 0.5, winSize.height * 0.5)];
        [self addSubview:indicatorView];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopIndicatorAnimat)
                                                     name:kD9StopIndicatorNotification
                                                   object:nil];
        
        if (isAuto) {
            [self performSelector:@selector(btnClicked:) withObject:_loginBtn afterDelay:0.5];
        }
        
        [MobClick event:@"d9LoginView"];
    }
    return self;
}

- (void) dealloc
{
    SAFE_RELEASE(_usernameTextField);
    SAFE_RELEASE(_passwordTextField);
    SAFE_RELEASE(userName);
    SAFE_RELEASE(_passWord);
    SAFE_RELEASE(indicatorView);
    SAFE_RELEASE(d9AppID);

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kD9StopIndicatorNotification
                                                  object:nil];
    
    delegate = nil;
    
    [super dealloc];
}

#pragma mark -- Private Method --

- (void) checkboxClicked:(UIButton *)btn
{
    if (btn == _rememberPassword) {
        [MobClick event:@"d9BtnRem"];
        isRemember = !isRemember;
    } else if (btn == _autoLogin) {
        [MobClick event:@"d9BtnAuto"];
        isAuto = !isAuto;
    }
    btn.selected = !btn.selected;
}

- (void) resignKeyboard
{
    if (_usernameTextField) {
        [_usernameTextField resignFirstResponder];
    }
    if (_passwordTextField) {
        [_passwordTextField resignFirstResponder];
    }
}

- (void) btnClicked:(UIButton *)sender
{
    [_passwordTextField setSecureTextEntry:YES];
    if (DEBUG_LOG) {
        NSLog(@"btn clicked.");
    }
    if (sender == _loginBtn) {
        [indicatorView startAnimating];
        if (DEBUG_LOG) {
            NSLog(@"Login btn pressed.");
        }
        
        self.userName = _usernameTextField.text;
//        self.passWord = _passwordTextField.text;
        [self setPassWord:_passwordTextField.text];
        
        if (DEBUG_LOG) {
            NSLog(@"login pressed:%@, %@", userName, _passWord);
        }
        
        if (![self isLoginInputValid]) {
            [indicatorView stopAnimating];
            return;
        }
        if ([_passWord length] != 32) {
            NSString* tmpString = [NSString stringWithFormat:@"%@%@", _passWord, userName];
            _passWord = [tmpString MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(loginDialog:withUsername:password:)]) {
            
            [delegate loginDialog:self withUsername:userName password:_passWord];
        }
        
        [MobClick event:@"d9BtnLogin"];
    } else if (sender == _toRegBtn) {
        [_rememberPassword setHidden:YES];
        [_autoLogin setHidden:YES];
        [_loginBtn setHidden:YES];
        [_toRegBtn setHidden:YES];
        [_toChangePwd setHidden:YES];
        
        [_toLogBtn setHidden:NO];
        [_regBtn setHidden:NO];
        [_randomBtn setHidden:NO];
        
        [_usernameTextField setText:@""];
        [_passwordTextField setText:@""];
        
        [MobClick event:@"d9BtnToReg"];
    } else if (sender == _toLogBtn) {
        [_rememberPassword setHidden:NO];
        [_autoLogin setHidden:NO];
        [_loginBtn setHidden:NO];
        [_toRegBtn setHidden:NO];
        [_toChangePwd setHidden:NO];
        
        [_toLogBtn setHidden:YES];
        [_regBtn setHidden:YES];
        [_randomBtn setHidden:YES];
        
        [_usernameTextField setText:userName];
        [_passwordTextField setText:_passWord];
        
        [MobClick event:@"d9BtnToLogin"];
    } else if (sender == _regBtn) {
        [indicatorView startAnimating];
        
        if (DEBUG_LOG) {
            NSLog(@"regist button pressed.");
        }
        self.userName = _usernameTextField.text;
//        self.passWord = _passwordTextField.text;
        [self setPassWord:_passwordTextField.text];
        
        if (![self isInputValid]) {
            [indicatorView stopAnimating];
            return;
        }
        if ([_passWord length] != 32) {
            NSString* tmpString = [NSString stringWithFormat:@"%@%@", _passWord, userName];
            _passWord = [tmpString MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(registDialog:withUsername:password:)]) {
            [delegate registDialog:self withUsername:userName password:_passWord];
        }
        
        [MobClick event:@"d9BtnReg"];
    } else if (sender == _randomBtn) {
        NSString *randomName = @"u";
        NSString *randomWord = @"";
        
        for (int i = 0; i < 6; i++) {
            int value = arc4random() % 10;
            randomName = [randomName stringByAppendingFormat:@"%d", value];
        }
        
        for (int i = 0; i < 6; i++) {
            int value = arc4random() % 10;
            randomWord = [randomWord stringByAppendingFormat:@"%d", value];
        }
        
        if (DEBUG_LOG) {
            NSLog(@"random name = %@, word = %@", randomName, randomWord);
        }
        
        _usernameTextField.text = randomName;
        _passwordTextField.text = randomWord;
        
        [_passwordTextField setSecureTextEntry:NO];
        
        [MobClick event:@"d9BtnRandom"];
    } else if (sender == _toChangePwd) {
        if ([delegate respondsToSelector:@selector(changePwdDialog:withUserName:)]) {
            [delegate changePwdDialog:self withUserName:userName];
        }
        [MobClick event:@"d9BtnToChange"];
    }
}

- (BOOL) isLoginInputValid
{
    if (!userName || !_passWord || [userName isEqual:@""] || [_passWord isEqual:@""]) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    return YES;
}

- (BOOL) isInputValid
{
    if (!userName || !_passWord || [userName isEqual:@""] || [_passWord isEqual:@""]) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    if ([userName length] < 6 || [_passWord length] < 6) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能少于6个字符"];
        return NO;
    }
    return YES;
}


- (void) saveSettingDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
//    [self saveAccountDataToKeychain];
    [D9SDKUtil saveToKeyChainUname:userName Pwd:_passWord AppId:d9AppID];
    
    NSString* remKey = [NSString stringWithFormat:@"%@%@", kD9DefaultRemember, d9AppID];
    [userDefault setBool:isRemember forKey:remKey];
    NSString* autoKey = [NSString stringWithFormat:@"%@%@", kD9DefaultAuto, d9AppID];
    [userDefault setBool:isAuto forKey:autoKey];
    
    [userDefault synchronize];
}

- (void) readSettingFromDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* remKey = [NSString stringWithFormat:@"%@%@", kD9DefaultRemember, d9AppID];
    isRemember = [userDefault boolForKey:remKey];
    NSString* autoKey = [NSString stringWithFormat:@"%@%@", kD9DefaultAuto, d9AppID];
    isAuto = [userDefault boolForKey:autoKey];
    

    self.userName = [D9SDKUtil readUnameFromKeyChainAppId:d9AppID];
//    self.passWord = [D9SDKUtil readPwdFromKeyChainAppId:d9AppID];
    [self setPassWord:[D9SDKUtil readPwdFromKeyChainAppId:d9AppID]];
    
    if (DEBUG_LOG) {
        NSLog(@"D9LoginDialog: readSettingFromDefault: username=%@", userName);
        NSLog(@"D9LoginDialog: readSettingFromDefault: password=%@", _passWord);
    }
}

- (void) deleteSettingInDefault
{

    self.userName = nil;
//    self.passWord = nil;
    [self setPassWord:nil];
    [D9SDKUtil deleteInKeyChainAppId:d9AppID];
    
    isRemember = true;
    isAuto = false;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString* remKey = [NSString stringWithFormat:@"%@%@", kD9DefaultRemember, d9AppID];
    [userDefault setBool:isRemember forKey:remKey];
    NSString* autoKey = [NSString stringWithFormat:@"%@%@", kD9DefaultAuto, d9AppID];
    [userDefault setBool:isAuto forKey:autoKey];
    
    [userDefault synchronize];
}

- (void) stopIndicatorAnimat
{
    if (DEBUG_LOG) {
        NSLog(@"stop indicator notificaton received.");
    }
    if (indicatorView) {
        [indicatorView stopAnimating];
    }
}

- (void) addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange:)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void) removeObservers
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIDeviceOrientationDidChangeNotification
                                                  object:nil];
}

#pragma mark -- TextField Delegate --

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameTextField) {
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
        //todo: may add Go btn login|regist function
    }
    
    return YES;
}

#pragma mark -- D9LoginDialog Public Methods

- (NSString *) passWord
{
    return _passWord;
}

- (void) setPassWord:(NSString *)passWord
{
    if (DEBUG_LOG) {
        NSLog(@"%@ new value:%@", _passWord, passWord);
    }
    if (passWord != _passWord) {
        [_passWord release];
        _passWord = [passWord retain];

        [_passwordTextField setText:_passWord];
    }
}

- (void) show:(BOOL)animated
{
    /* iOS5 bug, 第一次无法正确传入方向，statusBarOrientation第一次始终为portrait
     * 初始化view中，不是AppDelegate中，加入[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandScapeRight];
     */
    
    // 只有横版效果图和图素，只考虑横版，去除自适配。
//    [self sizeToFitOrientation:[self currentOrientation]];
    
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
    
    //--TODO: animated action
    // 只有横版效果图和图素，只考虑横版，去除自适配。
//    [self addObservers];
}

- (void) hide:(BOOL)animated
{
    [self removeObservers];
    //--TODO: animated action
    [self removeFromSuperview];
}

- (UIInterfaceOrientation)currentOrientation
{
//    return [[UIDevice currentDevice] orientation];
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    [self setTransform:CGAffineTransformIdentity];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        if (DEBUG_LOG) {
            NSLog(@"land scape.");
        }
        [self setFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
        
        winSize = [self frame].size;
        
        [resignBtn setFrame:[self frame]];
//        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad) {
        [_usernameTextField setFrame:CGRectMake(125, 70, kD9ScreenHeight-2*125, 30)];
        [_passwordTextField setFrame:CGRectMake(125, 110, kD9ScreenHeight-2*125, 30)];
        [_rememberPassword setFrame:CGRectMake(125, 150, 15, 15)];
        [_autoLogin setFrame:CGRectMake(winSize.width * 0.5, 150, 15, 15)];
        [_loginBtn setFrame:CGRectMake(125, 185, kD9ScreenHeight-2*125, 40)];
        [_toRegBtn setFrame:CGRectMake(kD9ScreenHeight * 0.5 - 100, 255, 200, 20)];
        [_regBtn setFrame:CGRectMake(125, 160, winSize.width * 0.5 - 130, 40)];
        [_randomBtn setFrame:CGRectMake(winSize.width * 0.5 + 5, 160, winSize.width * 0.5 - 130, 40)];
        [_toLogBtn setFrame:[_toRegBtn frame]];
        [indicatorView setCenter:CGPointMake(kD9ScreenHeight * 0.5, kD9ScreenWidth * 0.5)];
//        } else {
        //TODO:区分iPad和iPhone
//        }
        [self setCenter:CGPointMake(winSize.width * 0.5, winSize.height * 0.5)];
    }
    else
    {
        if (DEBUG_LOG) {
            NSLog(@"protrait.");
        }
        [self setFrame:CGRectMake(0, 0, kD9ScreenWidth, kD9ScreenHeight)];
        
        winSize = [self frame].size;
        
        [resignBtn setFrame:[self frame]];
        [_usernameTextField setFrame:CGRectMake(45, 150, kD9ScreenWidth-2*45, 30)];
        [_passwordTextField setFrame:CGRectMake(45, 190, kD9ScreenWidth-2*45, 30)];
        [_rememberPassword setFrame:CGRectMake(45, 230, 15, 15)];
        [_autoLogin setFrame:CGRectMake(winSize.width * 0.5, 230, 15, 15)];
        [_loginBtn setFrame:CGRectMake(45, 265, 230, 40)];
        [_toRegBtn setFrame:CGRectMake(kD9ScreenWidth * 0.5 - 100, 335, 200, 20)];
        [_regBtn setFrame:CGRectMake(45, 240, winSize.width * 0.5 - 50, 40)];
        [_randomBtn setFrame:CGRectMake(winSize.width * 0.5 + 5, 240, winSize.width * 0.5 - 50, 40)];
        [_toLogBtn setFrame:[_toRegBtn frame]];
        [indicatorView setCenter:CGPointMake(kD9ScreenWidth * 0.5, kD9ScreenHeight * 0.5)];
        [self setCenter:CGPointMake(winSize.width * 0.5, winSize.height * 0.5)];
    }
    
    [self setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
//    if (orientation == UIInterfaceOrientationLandscapeLeft) {
//        NSLog(@"land scape left");
////        return CGAffineTransformIdentity;
////        return CGAffineTransformMakeRotation(0);
////        return CGAffineTransformMakeRotation(-M_PI / 2);
//        return CGAffineTransformIdentity;
//    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
//        NSLog(@"land scape right");
////        return CGAffineTransformMakeRotation(-M_PI);
////        return CGAffineTransformMakeRotation(M_PI / 2);
//        return CGAffineTransformIdentity;
//    }
//    else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
//        NSLog(@"portrait upside down");
////        return CGAffineTransformMakeRotation(M_PI / 2);
//        return CGAffineTransformMakeRotation(-M_PI);
//    } else {
//        NSLog(@"portrait");
////        return CGAffineTransformMakeRotation(-M_PI / 2);
    return CGAffineTransformIdentity;
//    }
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == previousOrientation) {
		return NO;
	} else {
		return orientation == UIInterfaceOrientationLandscapeLeft
		|| orientation == UIInterfaceOrientationLandscapeRight
		|| orientation == UIInterfaceOrientationPortrait
		|| orientation == UIInterfaceOrientationPortraitUpsideDown;
	}
    return YES;
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [self currentOrientation];
	if ([self shouldRotateToOrientation:orientation]) {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}
@end
