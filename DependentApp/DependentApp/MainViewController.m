//
//  MainViewController.m
//  DependentApp
//
//  Created by 朱 俊杰 on 13-6-7.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "MainViewController.h"

#define kD9AppKey @"MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBANg4Vz5qc/IsOPum4DRV872BThifPtf5Dx2t/CnXf3v0qDc4IjPJwk6zawXWVn7KmTTatyvhw6CoXnJYHyBG74xwgRYD7gCIwpLddSxK0Y6iuiq1vhlEVFOWhpLvRtmNkG92ZiOdEPIpZZEgkurWEfBgdIu0v1nmm2oFsc4i7r0/AgMBAAECgYB2Y4MBnfAWbbhVsi2Y+mcXIDHOsYMLZkesjJNBpckb6f4hHg88JADMbtjuvUlm6y+wDQG2eUtQMGBmY3HHjo+iZ3oCzbqrkiYRKcIj3Sbvrnveu75n3BBwp7VgzRTl06qhkYvtY6VUhlUq+9dbNKuN6htjQniJFqjESmvosUV54QJBAP/jCCbt3siTFEO5fpiFGCShWbc3zecI7BzVIhumLgaa5cEykSQlps7Dv3POcPrOfAcf5/V/gpHWml1whqWyL2MCQQDYUNGCurjYWBtS2osWPd/z9JhS3rtEPMnW2ZZ6J2XsQpPO9YqoCrYyWuzc5EW4Zp8VqVq82pGQvTMOKDO7zSd1AkASEOJbdUHcYV315hvFAuiQdX/TCrKT1DJvWrDcyN/JAZilCj/rEGl1gaZ7s6CQZJGnIx6KW6VJTKB7Zl1rR2hHAkB349sq7Jh0d+i09CFwc1zDlkYyb/Y0rMhlhvVKwLlRx9iqNRbjagRvRkvPZclqmZ4EYHfFAhL5uJMqfoelx9/dAkAx0qffJLCyoOGF/EFD++6RLubofhdRcpwMgaDDj2LXmz8a95PK2/VDrzWlORj7A6Uv1pNY+EFYI2rTB8p5xiT3"

@interface MainViewController ()

- (void) payBtnClick;
- (void) logoutClick;

@end

@implementation MainViewController

//- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
//{
//    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (id) init {
    self = [super init];
    if (self) {
//        engine = [[D9StudioSDK alloc] initWithAppID:@"11111" andAppKey:@"22222"];
//        [engine autorelease];
//        [engine setDelegate:self];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.view setBackgroundColor:[UIColor whiteColor]];

    UILabel * lblMain = [[UILabel alloc] initWithFrame:CGRectMake(20, 40, 40, 25)];
    [lblMain setText:@"首页"];
    [lblMain setTextColor:[UIColor blackColor]];
    [lblMain setFont:[UIFont fontWithName:@"Times New Roman" size:20]];
    
    UIButton *payBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [payBtn setTitle:@"支付" forState:UIControlStateNormal];
    CGRect btnFram = CGRectMake(20, 80, 80, 44);
    [payBtn setFrame:btnFram];
    [payBtn addTarget:self action:@selector(payBtnClick) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *logoutBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [logoutBtn setTitle:@"登出" forState:UIControlStateNormal];
    CGRect logoutFram = CGRectMake(120, 80, 80, 44);
    [logoutBtn setFrame:logoutFram];
    [logoutBtn addTarget:self action:@selector(logoutClick) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:logoutBtn];
    [self.view addSubview:payBtn];
    [self.view addSubview:lblMain];
    [lblMain release];
    
    engine = [[D9StudioSDK alloc] initWithAppID:@"100001" andAppKey:kD9AppKey];
    [engine setDelegate:self];
    [engine login];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
    [engine setDelegate:nil];
    [engine release];
    engine = nil;
    
    [super dealloc];
}

#pragma mark -- Private
- (void) payBtnClick
{
    [engine enterPayViewWithRoleId:@"45" andGoodsId:@"100001-1" andGoodsCnt:@"1000" andGoodsName:@"钻石" andTotalMoney:@"31" andPayDes:@"fix bug next time"];
}

- (void) logoutClick
{
    [engine logout];
}

#pragma mark -- D9StudioSDK Delegate Methods
- (void) d9SDKDidLogin:(D9StudioSDK *)d9engine
{
    NSLog(@"Dependent App: D9StudioSDK Logged in.");
}

- (void) d9SDKDidLogOut:(D9StudioSDK *)d9engine
{
    NSLog(@"engine logout");
}

- (void) d9SDK:(D9StudioSDK *)d9engine didFailToLogInWithError:(NSError *)error
{
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
//    return YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
	}
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    
}

@end
