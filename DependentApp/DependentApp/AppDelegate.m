//
//  AppDelegate.m
//  DependentApp
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (void)dealloc
{
//    [engine setDelegate:nil];
//    [engine release];
//    engine = nil;
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    // Override point for customization after application launch.
    
    mainViewController = [[[MainViewController alloc] init] autorelease];
    self.window.rootViewController  = mainViewController;
    
//    engine = [[D9StudioSDK alloc] initWithAppID:@"11111" andAppKey:@"22222"];
//    [engine setDelegate:self];
//    [engine login];
    
//    if ([engine isLoggedIn]) {
//        NSLog(@"Dependent App engine UserID is:%@", engine.userID);
//    }
    application.statusBarHidden = YES;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

//#pragma mark -- D9StudioSDK Delegate Methods
//- (void) d9SDKDidLogin:(D9StudioSDK *)d9engine
//{
//    NSLog(@"Dependent App: D9StudioSDK Logged in.");
//}
//
//- (void) d9SDKDidLogOut:(D9StudioSDK *)d9engine
//{
//    
//}
//
//- (void) d9SDK:(D9StudioSDK *)d9engine didFailToLogInWithError:(NSError *)error
//{
//    
//}

@end
