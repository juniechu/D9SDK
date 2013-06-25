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

#define kD9DefaultUsername      @"D9Username"
#define kD9DefaultPassword      @"D9Password"
#define kD9DefaultRemember      @"D9Remember"

#define kFontTimes              @"Times New Roman"

@interface D9LoginDialog (Private)
- (void) checkboxClicked:(UIButton *)btn;
- (void) resignKeyboard;
- (void) btnClicked:(UIButton *)sender;
- (BOOL) isInputValid;

- (void) saveSettingToDefault;
- (void) readSettingFromDefault;
- (void) deleteSettingInDefault;

- (void) stopIndicatorAnimat;
@end

@implementation D9LoginDialog

@synthesize delegate;
@synthesize userName;
@synthesize passWord;

- (id)init
{
    self = [super initWithFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
    if (DEBUG_LOG) {
        NSLog(@"First:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        NSLog(@"D9LoginDialog init, changed?");
    }
    if (self) {
        // Initialization code
        
        CGRect winRect = CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth);
        winSize = winRect.size;
        if (DEBUG_LOG) {
            NSLog(@"Second:width:[%f], height[%f]", winSize.width, winSize.height);
        }

        
        [self readSettingFromDefault];
        isRemember = true;
        
        // 背景
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:200 alpha:0.8];
        self.autoresizesSubviews = YES;
//        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.contentMode = UIViewContentModeRedraw;
        
        // button to resign keyborad
        UIButton * resignBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [resignBtn setFrame:winRect];
        [resignBtn addTarget:self action:@selector(resignKeyboard) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:resignBtn];
        
        // Head Logo
        UIImage * logoImage = [UIImage imageNamed:@"d9_logo.png"];
        if (!logoImage) {
            NSLog(@"Resource not found! Please add Resource into your project.");
        }
        UIImageView * logoView = [[UIImageView alloc] initWithImage:logoImage];
        [logoView setFrame:CGRectMake(10, 10, logoImage.size.width * 0.5, logoImage.size.height * 0.5)];
        
        [self insertSubview:logoView belowSubview:resignBtn];
        [logoView release];
        
        // User Name
        UIView *usernameView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [usernameView setBackgroundColor:[UIColor grayColor]];
        UIImage * usernameImage = [UIImage imageNamed:@"d9_username.png"];
        UIImageView * usernameImageView = [[UIImageView alloc] initWithImage:usernameImage];
        [usernameImageView setFrame:CGRectMake(15 - usernameImage.size.width * 0.5, 15 - usernameImage.size.height * 0.5, usernameImage.size.width, usernameImage.size.height)];
        [usernameView addSubview:usernameImageView];
        [usernameImageView release];
        
        // landscape
//        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 150, 230, 30)];
        _usernameTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 70, 230, 30)];
        [_usernameTextField setBackgroundColor:[UIColor whiteColor]];
        [_usernameTextField setTextColor:[UIColor blackColor]];
        [_usernameTextField setDelegate:self];
        //TODO: use NSLocalizedString() instead
        [_usernameTextField setPlaceholder:@"用户名："];
        [_usernameTextField setTextAlignment:NSTextAlignmentLeft];
        [_usernameTextField setFont:[UIFont fontWithName:kFontTimes size:20]];
        [_usernameTextField setAdjustsFontSizeToFitWidth:NO];
        [_usernameTextField setBorderStyle:UITextBorderStyleNone];
        [_usernameTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_usernameTextField setLeftView:usernameView];
        [_usernameTextField setLeftViewMode:UITextFieldViewModeAlways];
        [_usernameTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_usernameTextField setReturnKeyType:UIReturnKeyNext];
        [_usernameTextField.window makeKeyWindow];
        [_usernameTextField.window makeKeyAndVisible];
        
        [usernameView release];
        
        [self insertSubview:_usernameTextField aboveSubview:resignBtn];
        
        if (userName) {
            [_usernameTextField setText:userName];
        }
        
        // Pass Word
        UIView * passwordView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        [passwordView setBackgroundColor:[UIColor grayColor]];
        UIImage * passwordImage = [UIImage imageNamed:@"d9_password.png"];
        UIImageView * passwordImageView = [[UIImageView alloc] initWithImage:passwordImage];
        [passwordImageView setFrame:CGRectMake(15 - passwordImage.size.width * 0.5, 15 - passwordImage.size.height * 0.5, passwordImage.size.width, passwordImage.size.height)];
        [passwordView addSubview:passwordImageView];
        [passwordImageView release];
        
//        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(45, 190, 230, 30)];
        _passwordTextField = [[UITextField alloc] initWithFrame:CGRectMake(125, 110, 230, 30)];
        [_passwordTextField setBackgroundColor:[UIColor whiteColor]];
        [_passwordTextField setTextColor:[UIColor blackColor]];
        [_passwordTextField setDelegate:self];
        [_passwordTextField setPlaceholder:@"密码："];
        [_passwordTextField setTextAlignment:NSTextAlignmentLeft];
        [_passwordTextField setFont:[UIFont fontWithName:kFontTimes size:20]];
        [_passwordTextField setAdjustsFontSizeToFitWidth:NO];
        [_passwordTextField setClearsOnBeginEditing:YES];
        [_passwordTextField setBorderStyle:UITextBorderStyleNone];
        [_passwordTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
        [_passwordTextField setLeftView:passwordView];
        [_passwordTextField setLeftViewMode:UITextFieldViewModeAlways];
        [_passwordTextField setContentVerticalAlignment:UIControlContentVerticalAlignmentCenter];
        [_passwordTextField setSecureTextEntry:YES];
        [_passwordTextField setReturnKeyType:UIReturnKeyGo];
        
        [passwordView release];
        
        //        [self addSubview:_passwordTextField];
        [self insertSubview:_passwordTextField aboveSubview:resignBtn];
        
        if (isRemember && passWord) {
            [_passwordTextField setText:passWord];
        }
        
        // Remember Password
        _rememberPassword = [UIButton buttonWithType:UIButtonTypeCustom];
//        CGRect rememberCheckboxRect = CGRectMake(45, 230, 15, 15);
        CGRect rememberCheckboxRect = CGRectMake(125, 150, 15, 15);
        [_rememberPassword setFrame:rememberCheckboxRect];
        
        [_rememberPassword setImage:[UIImage imageNamed:@"d9_checkbox_false.png"] forState:UIControlStateNormal];
        [_rememberPassword setImage:[UIImage imageNamed:@"d9_checkbox_focus.png"] forState:UIControlStateHighlighted];
        [_rememberPassword setImage:[UIImage imageNamed:@"d9_checkbox_true.png"] forState:UIControlStateSelected];
        
        [_rememberPassword addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_rememberPassword aboveSubview:resignBtn];
        
        if (isRemember) {
            [_rememberPassword setSelected:YES];
        }
        
//        _lblRemember = [[UILabel alloc] initWithFrame:CGRectMake(60, 230, winSize.width * 0.5 - 60, 15)];
        _lblRemember = [[UILabel alloc] initWithFrame:CGRectMake(140, 150, winSize.width * 0.5 - 140, 15)];
        [_lblRemember setBackgroundColor:[UIColor clearColor]];
        [_lblRemember setFont:[UIFont fontWithName:kFontTimes size:13]];
        [_lblRemember setText:@"记住密码"];
        [_lblRemember setTextColor:[UIColor whiteColor]];
        //        [lblRemember setShadowColor:[UIColor colorWithWhite:0.1 alpha:0.8]];
        //        [lblRemember setShadowOffset:CGSizeMake(1.0, 1.0)];
        [_lblRemember setTextAlignment:NSTextAlignmentLeft];
        
        [self insertSubview:_lblRemember belowSubview:resignBtn];
        
        
        // Auto Login
        _autoLogin = [UIButton buttonWithType:UIButtonTypeCustom];
//        CGRect autoCheckboxRect = CGRectMake(winSize.width * 0.5, 230, 15, 15);
        CGRect autoCheckboxRect = CGRectMake(winSize.width * 0.5, 150, 15, 15);
        [_autoLogin setFrame:autoCheckboxRect];
        
        [_autoLogin setImage:[UIImage imageNamed:@"d9_checkbox_false.png"] forState:UIControlStateNormal];
        [_autoLogin setImage:[UIImage imageNamed:@"d9_checkbox_focus.png"] forState:UIControlStateHighlighted];
        [_autoLogin setImage:[UIImage imageNamed:@"d9_checkbox_true.png"] forState:UIControlStateSelected];
        
        [_autoLogin addTarget:self action:@selector(checkboxClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_autoLogin aboveSubview:resignBtn];
        
        if (isAuto) {
            [_autoLogin setSelected:YES];
        }
        
//        _lblAuto = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width * 0.5 + 15, 230, winSize.width * 0.5 - 60, 15)];
        _lblAuto = [[UILabel alloc] initWithFrame:CGRectMake(winSize.width * 0.5 + 15, 150, winSize.width * 0.5 - 140, 15)];
        [_lblAuto setBackgroundColor:[UIColor clearColor]];
        [_lblAuto setFont:[UIFont fontWithName:kFontTimes size:13]];
        [_lblAuto setText:@"自动登陆"];
        [_lblAuto setTextColor:[UIColor whiteColor]];
        [_lblAuto setTextAlignment:NSTextAlignmentLeft];
        
        [self insertSubview:_lblAuto belowSubview:resignBtn];
        
        // Login Button
        _loginBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_loginBtn setFrame:CGRectMake(45, 265, 230, 40)];
        [_loginBtn setFrame:CGRectMake(125, 185, 230, 40)];
        
        
        [_loginBtn setTitle:@"登陆" forState:UIControlStateNormal];
        [_loginBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_loginBtn.titleLabel setFont:[UIFont fontWithName:kFontTimes size:15]];
        
        
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_normal.png"] forState:UIControlStateNormal];
        [_loginBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_down.png"] forState:UIControlStateSelected];
        
        
        [_loginBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:_loginBtn aboveSubview:resignBtn];
        
        
        // To Register Button
        _toRegBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_toRegBtn setFrame:CGRectMake(60, 335, 200, 20)];
        [_toRegBtn setFrame:CGRectMake(140, 255, 200, 20)];
        
        [_toRegBtn setTitle:@"还没账号？快来这里注册！" forState:UIControlStateNormal];
        [_toRegBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_toRegBtn.titleLabel setFont:[UIFont fontWithName:kFontTimes size:15]];
        
        [_toRegBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_toRegBtn aboveSubview:resignBtn];
        
        
        // Register Button
        _regBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_regBtn setFrame:CGRectMake(45, 240, winSize.width * 0.5 - 50, 40)];
        [_regBtn setFrame:CGRectMake(125, 160, winSize.width * 0.5 - 130, 40)];
        
        [_regBtn setTitle:@"注册" forState:UIControlStateNormal];
        [_regBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_regBtn.titleLabel setFont:[UIFont fontWithName:kFontTimes size:15]];
        
        [_regBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_normal.png"] forState:UIControlStateNormal];
        [_regBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_down.png"] forState:UIControlStateSelected];
        
        [_regBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_regBtn aboveSubview:resignBtn];
        [_regBtn setHidden:YES];
        
        
        // Random Button
        _randomBtn = [UIButton buttonWithType:UIButtonTypeCustom];
//        [_randomBtn setFrame:CGRectMake(winSize.width * 0.5 + 5, 240, winSize.width * 0.5 - 50, 40)];
        [_randomBtn setFrame:CGRectMake(winSize.width * 0.5 + 5, 160, winSize.width * 0.5 - 130, 40)];
        [_randomBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_randomBtn setTitle:@"随机账号" forState:UIControlStateNormal];
        [_randomBtn.titleLabel setFont:[UIFont fontWithName:kFontTimes size:15]];
        
        [_randomBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_normal.png"] forState:UIControlStateNormal];
        [_randomBtn setBackgroundImage:[UIImage imageNamed:@"d9_button_down.png"] forState:UIControlStateSelected];
        
        [_randomBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_randomBtn aboveSubview:resignBtn];
        [_randomBtn setHidden:YES];
        
        // To Login Button
        _toLogBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_toLogBtn setFrame:[_toRegBtn frame]];
        
        [_toLogBtn setTitle:@"已有账号了？点这里登录！" forState:UIControlStateNormal];
        [_toLogBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_toLogBtn.titleLabel setFont:[UIFont fontWithName:kFontTimes size:15]];
        
        [_toLogBtn addTarget:self action:@selector(btnClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self insertSubview:_toLogBtn aboveSubview:resignBtn];
        [_toLogBtn setHidden:YES];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
//        [indicatorView setCenter:CGPointMake(160, 240)];
        [indicatorView setCenter:CGPointMake(240, 160)];
        [self addSubview:indicatorView];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(stopIndicatorAnimat)
                                                     name:kD9StopIndicatorNotification
                                                   object:nil];
        
        if (isAuto) {
            [self performSelector:@selector(btnClicked:) withObject:_loginBtn afterDelay:0.5];
        }
        
    }
    return self;
}

- (void) dealloc
{
    [_usernameTextField release], _usernameTextField = nil;
    [_passwordTextField release], _passwordTextField = nil;
    [_lblRemember release], _lblRemember = nil;
    [_lblAuto release], _lblAuto = nil;
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
        isRemember = !isRemember;
    } else if (btn == _autoLogin) {
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
        
        if (![self isInputValid]) {
            return;
        }
        if ([passWord length] != 32) {
            passWord = [passWord MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(loginDialog:withUsername:password:)]) {
            
            [delegate loginDialog:self withUsername:userName password:passWord];
        }
        
        
    } else if (sender == _toRegBtn) {
        [_rememberPassword setHidden:YES];
        [_autoLogin setHidden:YES];
        [_lblRemember setHidden:YES];
        [_lblAuto setHidden:YES];
        [_loginBtn setHidden:YES];
        [_toRegBtn setHidden:YES];
        
        [_toLogBtn setHidden:NO];
        [_regBtn setHidden:NO];
        [_randomBtn setHidden:NO];
    } else if (sender == _toLogBtn) {
        [_rememberPassword setHidden:NO];
        [_autoLogin setHidden:NO];
        [_lblRemember setHidden:NO];
        [_lblAuto setHidden:NO];
        [_loginBtn setHidden:NO];
        [_toRegBtn setHidden:NO];
        
        [_toLogBtn setHidden:YES];
        [_regBtn setHidden:YES];
        [_randomBtn setHidden:YES];
    } else if (sender == _regBtn) {
        [indicatorView startAnimating];
        
        if (DEBUG_LOG) {
            NSLog(@"regist button pressed.");
        }
        self.userName = _usernameTextField.text;
        self.passWord = _passwordTextField.text;
        
        if (![self isInputValid]) {
            return;
        }
        if ([passWord length] != 32) {
            passWord = [passWord MD5EncodedString];
        }
        [self saveSettingDefault];
        
        if ([delegate respondsToSelector:@selector(registDialog:withUsername:password:)]) {
            [delegate registDialog:self withUsername:userName password:passWord];
        }

        
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
    }
}

- (BOOL) isInputValid
{
    if (!userName || !passWord) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能为空"];
        return NO;
    }
    if ([userName length] < 6 || [passWord length] < 6) {
        [D9SDKUtil showAlertViewWithMsg:@"账号密码不能少于6个字符"];
        return NO;
    }
    return YES;
}

- (void) saveSettingDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:userName forKey:kD9DefaultUsername];
    if (isRemember) {
        [userDefault setObject:passWord forKey:kD9DefaultPassword];
    }
    [userDefault setBool:isRemember forKey:kD9DefaultRemember];
    [userDefault setBool:isAuto forKey:kD9DefaultAuto];
    
    [userDefault synchronize];
}

- (void) readSettingFromDefault
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    isRemember = [userDefault boolForKey:kD9DefaultRemember];
    isAuto = [userDefault boolForKey:kD9DefaultAuto];
    self.userName = [userDefault stringForKey:kD9DefaultUsername];
    if (isRemember) {
        self.passWord = [userDefault stringForKey:kD9DefaultPassword];
    }
    if (DEBUG_LOG) {
        NSLog(@"D9LoginDialog: readSettingFromDefault: username=%@", userName);
    }
}

- (void) deleteSettingInDefault
{
    self.userName = nil;
    self.passWord = nil;
    isRemember = true;
    isAuto = false;

    [self saveSettingDefault];
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

#pragma mark -- TextField Delegate --

- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    if (textField == _usernameTextField) {
        [_usernameTextField resignFirstResponder];
        [_passwordTextField becomeFirstResponder];
    } else if (textField == _passwordTextField) {
        [textField resignFirstResponder];
    }
    return YES;
}

#pragma mark -- D9LoginDialog Public Methods

- (void) show:(BOOL)animated
{
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
    
    
    //TODO: animated action
}

- (void) hide:(BOOL)animated
{
    //TODO: animated action
    [self removeFromSuperview];
}

- (UIInterfaceOrientation)currentOrientation
{
    NSLog(@"current orientation.");
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    [self setTransform:CGAffineTransformIdentity];
    
    NSLog(@"size to fit orientation.");
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        NSLog(@"Land Scape:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        [self setFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
//        [panelView setFrame:CGRectMake(10, 10, kD9ScreenHeight - 20, kD9ScreenWidth - 20)];
//        [containerView setFrame:CGRectMake(10, 10, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
//        [webView setFrame:CGRectMake(0, 0, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
        [indicatorView setCenter:CGPointMake(kD9ScreenHeight * 0.5, kD9ScreenWidth * 0.5)];
    }
    else
    {
        NSLog(@"Portain Scape:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        [self setFrame:CGRectMake(0, 0, kD9ScreenWidth, kD9ScreenHeight)];
//        [panelView setFrame:CGRectMake(10, 10, kD9ScreenWidth - 20, kD9ScreenHeight - 20)];
//        [containerView setFrame:CGRectMake(10, 10, kD9ScreenWidth - 40, kD9ScreenHeight - 40)];
//        [webView setFrame:CGRectMake(0, 0, kD9ScreenWidth - 40, kD9ScreenHeight - 40)];
        [indicatorView setCenter:CGPointMake(kD9ScreenWidth * 0.5, kD9ScreenHeight * 0.5)];
    }
    
    [self setCenter:CGPointMake(kD9ScreenWidth * 0.5, kD9ScreenHeight * 0.5)];
    
    [self setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
    //	if (orientation == UIInterfaceOrientationLandscapeLeft)
    //    {
    //		return CGAffineTransformMakeRotation(-M_PI / 2);
    //	}
    //    else if (orientation == UIInterfaceOrientationLandscapeRight)
    //    {
    //		return CGAffineTransformMakeRotation(M_PI / 2);
    //	}
    //    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    //    {
    //		return CGAffineTransformMakeRotation(-M_PI);
    //	}
    //    else
    //    {
    NSLog(@"transform for orientation.");
    return CGAffineTransformIdentity;
    //	}
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == previousOrientation)
    {
		return NO;
	}
    else
    {
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
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}
@end
