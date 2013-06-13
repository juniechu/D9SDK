//
//  MainViewController.m
//  DependentApp
//
//  Created by 朱 俊杰 on 13-6-7.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

- (void) payBtnClick;

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
    
    
    [self.view addSubview:payBtn];
    [self.view addSubview:lblMain];
    [lblMain release];

    engine = [[D9StudioSDK alloc] initWithAppID:@"100001" andAppKey:@""];
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

#pragma mark -- D9StudioSDK Delegate Methods
- (void) d9SDKDidLogin:(D9StudioSDK *)d9engine
{
    NSLog(@"Dependent App: D9StudioSDK Logged in.");
}

- (void) d9SDKDidLogOut:(D9StudioSDK *)d9engine
{
    
}

- (void) d9SDK:(D9StudioSDK *)d9engine didFailToLogInWithError:(NSError *)error
{
    
}

@end
