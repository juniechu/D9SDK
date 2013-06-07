//
//  D9StudioSDK.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "D9Request.h"
#import "D9LoginDialog.h"

@class D9StudioSDK;

@protocol D9StudioSDKDelegate <NSObject>

@optional

// log in successfully
- (void) d9SDKDidLogin:(D9StudioSDK *)d9engine;

- (void) d9SDK:(D9StudioSDK *)d9engine didFailToLogInWithError:(NSError *)error;

- (void) d9SDKDidLogOut:(D9StudioSDK *)d9engine;

@end

@interface D9StudioSDK : NSObject <D9LoginDialogDelegate, D9RequestDelegate> {
    NSString    *appID;
    NSString    *appKey;
    
    NSString    *userID;
    
    D9Request   *request;
    
    int         sceneType;
    
    D9LoginDialog *loginView;
    
    id<D9StudioSDKDelegate> delegate;
}

@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) D9Request *request;
@property (nonatomic, assign) id<D9StudioSDKDelegate> delegate;
//@property (nonatomic, retain) D9LoginDialog * loginView;

/*
 * Initialize an instance with your client AppID and AppKey
 */
- (id) initWithAppID:(NSString *)theAppID andAppKey:(NSString *)theAppKey;

/* log in method, open the login dialog.
 * If succeed, d9SDKDidLogin will be called.
 */
- (void) login;

/* Log out.
 * If succeed, d9SDKDidLogOut will be called. 
 */
- (void) logout;

/* 
 *Check if user has logged in
 */
- (BOOL) isLoggedIn;

/* 
 */

@end
