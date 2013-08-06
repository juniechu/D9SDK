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
#import "SFHFKeychainUtils.h"
#import "MobClick.h"

#define kD9URLSchemePrefix              @"D9_"
#define kD9KeychainServiceNameSuffix    @"_ServiceName"
#define kD9KeychainUsername             @"D9Username"
#define kD9keychainPassword             @"D9Password"

#define kD9DefaultRemember      @"D9Remember"

#define kFontTimes              @"Times New Roman"

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

- (NSString *) urlSchemeString;
- (void) saveAccountDataToKeychain;
- (void) readAccountDataFromKeychain;
- (void) deleteAccountDataInKeychain;

- (void) stopIndicatorAnimat;

- (void) addObservers;
- (void) removeObservers;
@end

@implementation D9LoginDialog

@synthesize delegate;
@synthesize userName;
@synthesize passWord;
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
        
        CGRect winRect = CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth);
        winSize = winRect.size;
        if (DEBUG_LOG) {
            NSLog(@"Second:width:[%f], height[%f]", winSize.width, winSize.height);
        }
        
        [self readSettingFromDefault];
        isRemember = true;
        
        // 背景
        NSBundle* bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"D9Resource" ofType:@"bundle"]];
        NSString* bgPath = [bundle pathForResource:@"d9_background" ofType:@"jpg"];
        self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithContentsOfFile:bgPath]];
        self.autoresizesSubviews = YES;
        
        // button to resign keyborad
        resignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resignBtn setFrame:winRect];
        [resignBtn addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resignBtn];
        
        // Head Logo
        NSString* logoPath = [bundle pathForResource:@"d9_logo" ofType:@"png"];
        UIImage* logoImage = [UIImage imageWithContentsOfFile:logoPath];
        if (!logoImage) {
            NSLog(@"D9StudioSDK >> [Resource not found! Please add Resource into your project.]");
        }
        UIImageView * logoView = [[UIImageView alloc] initWithImage:logoImage];
        [logoView setFrame:CGRectMake((kD9ScreenHeight - logoImage.size.width) * 0.5, 30, logoImage.size.width, logoImage.size.height)];
        
        [self insertSubview:logoView belowSubview:resignBtn];
        [logoView release];
        
        // User Name
        NSString* usernamePath = [bundle pathForResource:@"d9_username" ofType:@"png"];
        UIImage* usernameImage = [UIImage imageWithContentsOfFile:usernamePath];
        
        UIImageView * usernameImageView = [[UIImageView alloc] initWithImage:usernameImage];
        [usernameImageView setFrame:CGRectMake(305, 274, 416, 36)];
        [self insertSubview:usernameImageView aboveSubview:resignBtn];
        
        // landscape
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(362, 274, 350, 36)];
        [_usernameTextField setBackgroundColor:[UIColor clearColor]];
        [_usernameTextField setTextColor:[UIColor blackColor]];
        [_usernameTextField setDelegate:self];
        //TODO: use NSLocalizedString() instead
        [_usernameTextField setPlaceholder:@"用户名："];
        [_usernameTextField setTextAlignment:NSTextAlignmentLeft];
        [_usernameTextField setFont:[UIFont fontWithName:kFontTimes size:18]];
        [_usernameTextField setAdjustsFontSizeToFitWidth:NO];
        [_usernameTextField setBorderStyle:UITextBorderStyleNone];
        [_usernameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_usernameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_usernameTextField setReturnKeyType:UIReturnKeyNext];
        [_usernameTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
        [_usernameTextField setAutocorrectionType:UITextAutocorrectionTypeNo];
        
        [self insertSubview:_usernameTextField aboveSubview:usernameImageView];
        
        if (userName) {
            [_usernameTextField setText:userName];
        }
        
        // Pass Word
        NSString* passwordPath = [bundle pathForResource:@"d9_password" ofType:@"png"];
        UIImage* passwordImage = [UIImage imageWithContentsOfFile:passwordPath];
        UIImageView * passwordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [passwordImageView setFrame:CGRectMake(305, 321, 416, 36)];
        [self insertSubview:passwordImageView aboveSubview:resignBtn];

        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(362, 321, 350, 36)];
        [_passwordTextField setBackgroundColor:[UIColor clearColor]];
        [_passwordTextField setTextColor:[UIColor blackColor]];
        [_passwordTextField setDelegate:self];
        [_passwordTextField setPlaceholder:@"密码："];
        [_passwordTextField setTextAlignment:NSTextAlignmentLeft];
        [_passwordTextField setFont:[UIFont fontWithName:kFontTimes size:18]];
        [_passwordTextField setAdjustsFontSizeToFitWidth:NO];
        [_passwordTextField setClearsOnBeginEditing:YES];
        [_passwordTextField setBorderStyle:UITextBorderStyleNone];
        [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_passwordTextField setSecureTextEntry:YES];
        [_passwordTextField setReturnKeyType:UIReturnKeyGo];

        [self insertSubview:_passwordTextField aboveSubview:passwordImageView];
        
        if (isRemember && passWord) {
            [_passwordTextField setText:passWord];
        }
        
        // Remember Password
        _rememberPassword = [UIButton buttonWithType:UIButtonTypeCustom];

        CGRect rememberCheckboxRect = CGRectMake(376, 378, 96, 21);
        [_rememberPassword setFrame:rememberCheckboxRect];
        
        NSString* rememberFalsePath = [bundle pathForResource:@"d9_remember_false" ofType:@"png"];
        UIImage* rememberFalseImage = [UIImage imageWithContentsOfFile:rememberFalsePath];
        [_rememberPassword setImage:rememberFalseImage forState:UIControlStateNormal];
        
        NSString* rememberTruePath = [bundle pathForResource:@"d9_remember_true" ofType:@"png"];
        UIImage* rememberTrueImage = [UIImage imageWithContentsOfFile:rememberTruePath];
        [_rememberPassword setImage:rememberTrueImage forState:UIControlStateSelected];
        
        [_rememberPassword addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_rememberPassword aboveSubview:resignBtn];
        
        if (isRemember) {
            [_rememberPassword setSelected:YES];
        }
        
        
        // Auto Login
        _autoLogin = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect autoCheckboxRect = CGRectMake(532, 378, 96, 21);
        [_autoLogin setFrame:autoCheckboxRect];

        NSString* autologinFalsePath = [bundle pathForResource:@"d9_autologin_false" ofType:@"png"];
        UIImage* autologinFalseImage = [UIImage imageWithContentsOfFile:autologinFalsePath];
        [_autoLogin setImage:autologinFalseImage forState:UIControlStateNormal];
        
        NSString* autologinTruePath = [bundle pathForResource:@"d9_autologin_true" ofType:@"png"];
        UIImage* autologinTrueImage = [UIImage imageWithContentsOfFile:autologinTruePath];
        [_autoLogin setImage:autologinTrueImage forState:UIControlStateSelected];
        
        [_autoLogin addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_autoLogin aboveSubview:resignBtn];
        
        if (isAuto) {
            NSLog(@"it is auto.");
            [_autoLogin setSelected:YES];
        }
        
        // Login Button
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginBtn setFrame:CGRectMake(359, 419, 309, 39)];
        
        NSString* btnLoginNormalPath = [bundle pathForResource:@"d9_button_login" ofType:@"png"];
        UIImage* btnLoginNormalImage = [UIImage imageWithContentsOfFile:btnLoginNormalPath];
        [_loginBtn setBackgroundImage:btnLoginNormalImage forState:UIControlStateNormal];
        
        NSString* btnLoginPressedPath = [bundle pathForResource:@"d9_button_login_pressed" ofType:@"png"];
        UIImage* btnLoginPressedImage = [UIImage imageWithContentsOfFile:btnLoginPressedPath];
        [_loginBtn setBackgroundImage:btnLoginPressedImage forState:UIControlStateSelected];
        
        
        [_loginBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_loginBtn aboveSubview:resignBtn];
        
        
        // To Register Button
        _toRegBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toRegBtn setFrame:CGRectMake(412, 473, 200, 20)];

        NSString* btnRegistHerePath = [bundle pathForResource:@"d9_regist_here" ofType:@"png"];
        UIImage* btnRegistHereImage = [UIImage imageWithContentsOfFile:btnRegistHerePath];
        [_toRegBtn setBackgroundImage:btnRegistHereImage forState:UIControlStateNormal];
        
        [_toRegBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_toRegBtn aboveSubview:resignBtn];
        
        
        // Register Button
        _regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_regBtn setFrame:CGRectMake(347, 392, 153, 39)];
        
        NSString* btnRegistPath = [bundle pathForResource:@"d9_button_regist" ofType:@"png"];
        UIImage* btnRegistImage = [UIImage imageWithContentsOfFile:btnRegistPath];
        [_regBtn setBackgroundImage:btnRegistImage forState:UIControlStateNormal];
        
        NSString* btnRegistPressedPath = [bundle pathForResource:@"d9_button_regist_pressed" ofType:@"png"];
        UIImage* btnRegistPressedImage = [UIImage imageWithContentsOfFile:btnRegistPressedPath];
        [_regBtn setBackgroundImage:btnRegistPressedImage forState:UIControlStateSelected];
        
        [_regBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_regBtn aboveSubview:resignBtn];
        [_regBtn setHidden:YES];
        
        
        // Random Button
        _randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_randomBtn setFrame:CGRectMake(526, 392, 153, 39)];

        
        NSString* btnRandomPath = [bundle pathForResource:@"d9_button_random" ofType:@"png"];
        UIImage* btnRandomImage = [UIImage imageWithContentsOfFile:btnRandomPath];
        [_randomBtn setBackgroundImage:btnRandomImage forState:UIControlStateNormal];
        
        NSString* btnRandomPressedPath = [bundle pathForResource:@"d9_button_random_pressed" ofType:@"png"];
        UIImage* btnRandomPressedImage = [UIImage imageWithContentsOfFile:btnRandomPressedPath];
        [_randomBtn setBackgroundImage:btnRandomPressedImage forState:UIControlStateSelected];
        
        [_randomBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_randomBtn aboveSubview:resignBtn];
        [_randomBtn setHidden:YES];
        
        // To Login Button
        _toLogBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toLogBtn setFrame:CGRectMake(410, 454, 207, 17)];

        
        NSString* btnToLoginPath = [bundle pathForResource:@"d9_login_here" ofType:@"png"];
        UIImage* btnToLoginImage = [UIImage imageWithContentsOfFile:btnToLoginPath];
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
    [_usernameTextField release], _usernameTextField = nil;
    [_passwordTextField release], _passwordTextField = nil;
    [userName release], userName = nil;
    [passWord release], passWord = nil;
    
    [indicatorView release], indicatorView = nil;
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
        self.passWord = _passwordTextField.text;
        
        if (DEBUG_LOG) {
            NSLog(@"%@, %@", userName, passWord);
        }
        
        if (![self isLoginInputValid]) {
            [indicatorView stopAnimating];
            return;
        }
        if ([passWord length] != 32) {
            NSString* tmpString = [NSString stringWithFormat:@"%@%@", passWord, userName];
            passWord = [tmpString MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(loginDialog:withUsername:password:)]) {
            
            [delegate loginDialog:self withUsername:userName password:passWord];
        }
        
        [MobClick event:@"d9BtnLogin"];
    } else if (sender == _toRegBtn) {
        [_rememberPassword setHidden:YES];
        [_autoLogin setHidden:YES];
        [_loginBtn setHidden:YES];
        [_toRegBtn setHidden:YES];
        
        [_toLogBtn setHidden:NO];
        [_regBtn setHidden:NO];
        [_randomBtn setHidden:NO];
        
        [MobClick event:@"d9BtnToReg"];
    } else if (sender == _toLogBtn) {
        [_rememberPassword setHidden:NO];
        [_autoLogin setHidden:NO];
        [_loginBtn setHidden:NO];
        [_toRegBtn setHidden:NO];
        
        [_toLogBtn setHidden:YES];
        [_regBtn setHidden:YES];
        [_randomBtn setHidden:YES];
        
        [MobClick event:@"d9BtnToLogin"];
    } else if (sender == _regBtn) {
        [indicatorView startAnimating];
        
        if (DEBUG_LOG) {
            NSLog(@"regist button pressed.");
        }
        self.userName = _usernameTextField.text;
        self.passWord = _passwordTextField.text;
        
        if (![self isInputValid]) {
            [indicatorView stopAnimating];
            return;
        }
        if ([passWord length] != 32) {
            NSString* tmpString = [NSString stringWithFormat:@"%@%@", passWord, userName];
            passWord = [tmpString MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(registDialog:withUsername:password:)]) {
            [delegate registDialog:self withUsername:userName password:passWord];
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
    }
}

- (BOOL) isLoginInputValid
{
    if (!userName || !passWord || [userName isEqual:@""] || [passWord isEqual:@""]) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    return YES;
}

- (BOOL) isInputValid
{
    if (!userName || !passWord || [userName isEqual:@""] || [passWord isEqual:@""]) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    if ([userName length] < 6 || [passWord length] < 6) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能少于6个字符"];
        return NO;
    }
    return YES;
}

- (NSString *) urlSchemeString
{
    return [NSString stringWithFormat:@"%@%@", kD9URLSchemePrefix, d9AppID];
}

- (void) saveAccountDataToKeychain
{
    NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    [SFHFKeychainUtils storeUsername:kD9KeychainUsername
                         andPassword:self.userName
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
    
    [SFHFKeychainUtils storeUsername:kD9keychainPassword
                         andPassword:self.passWord
                      forServiceName:serviceName
                      updateExisting:YES
                               error:nil];
}

- (void) readAccountDataFromKeychain
{
    NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    self.userName = [SFHFKeychainUtils getPasswordForUsername:kD9KeychainUsername
                                               andServiceName:serviceName
                                                        error:nil];
    
    self.passWord = [SFHFKeychainUtils getPasswordForUsername:kD9keychainPassword
                                               andServiceName:serviceName
                                                        error:nil];
}

- (void) deleteAccountDataInKeychain
{
    self.userName = nil;
    self.passWord = nil;
    
    NSString* serviceName = [[self urlSchemeString] stringByAppendingString:kD9KeychainServiceNameSuffix];
    
    [SFHFKeychainUtils deleteItemForUsername:kD9KeychainUsername
                              andServiceName:serviceName
                                       error:nil];
    [SFHFKeychainUtils deleteItemForUsername:kD9keychainPassword
                              andServiceName:serviceName
                                       error:nil];
}

- (void) saveSettingDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [self saveAccountDataToKeychain];
    
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

    [self readAccountDataFromKeychain];
    if (DEBUG_LOG) {
        NSLog(@"D9LoginDialog: readSettingFromDefault: username=%@", userName);
    }
}

- (void) deleteSettingInDefault
{
    [self deleteAccountDataInKeychain];
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
    }

//    [textField resignFirstResponder];

    return YES;
}

#pragma mark -- D9LoginDialog Public Methods

- (void) show:(BOOL)animated
{
    /* iOS5 bug, 第一次无法正确传入方向，statusBarOrientation第一次始终为portrait
     * 初始化view中，不是AppDelegate中，加入[[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandScapeRight];
     */
    
    // 只有iPad效果图和图素，只考虑iPad，去除自适配。
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
    // 只有iPad效果图和图素，只考虑iPad，去除自适配。
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
