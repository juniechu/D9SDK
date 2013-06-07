//
//  MainViewController.m
//  DependentApp
//
//  Created by 朱 俊杰 on 13-6-7.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

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
    
    [self.view addSubview:lblMain];

//    [engine login];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) dealloc
{
//    [engine setDelegate:nil];
//    [engine release];
//    engine = nil;
    
    [super dealloc];
}

#pragma mark - D9StudioSDK Delegate Method


@end
