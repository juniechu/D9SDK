//
//  D9StudioSDK.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

//#import "D9Request.h"
//#import "D9LoginDialog.h"

@class D9StudioSDK;
@class D9Request;
@class D9LoginDialog;
@class D9ChangePwdView;

@protocol D9StudioSDKDelegate <NSObject>

@optional

// log in successfully
- (void) d9SDKDidLogin:(D9StudioSDK *)d9engine;

- (void) d9SDK:(D9StudioSDK *)d9engine didFailToLogInWithError:(NSError *)error;

- (void) d9SDKDidLogOut:(D9StudioSDK *)d9engine;

@end

//@interface D9StudioSDK : NSObject <D9LoginDialogDelegate, D9RequestDelegate> {
@interface D9StudioSDK : NSObject {
    NSString    *appID;
    NSString    *appKey;
    
    NSString    *userID;
    
    D9Request   *request;
    
    int         sceneType;
    
    D9LoginDialog *loginView;
    D9ChangePwdView* changeView;
    
    id<D9StudioSDKDelegate> delegate;
}

@property (nonatomic, retain) NSString *appID;
@property (nonatomic, retain) NSString *appKey;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) D9Request *request;
@property (nonatomic, assign) id<D9StudioSDKDelegate> delegate;

/*
 * Initialize an instance with your client AppID and AppKey
 */
- (id) initWithAppID:(NSString *)theAppID andAppKey:(NSString *)theAppKey;

/* Log in method, open the login dialog.
 * If succeed, d9SDKDidLogin will be called,
 * Else, d9SDK didFailToLogInWithError will be called.
 */
- (void) login;

/* Log out.
 * If succeed, d9SDKDidLogOut will be called. 
 */
- (void) logout;

/* 
 * Check if user has logged in
 */
- (BOOL) isLoggedIn;

/* Pay View, open the pay view dialog
 * @param roleID the login account role id
 * @param goodsId your goods id
 * @param goodsCnt your buy goods count
 * @param goodsName your goods name
 * @param totalMoney your goods cost in CNY
 * @param payDescription extra description, can be nil or ""
 */
- (void) enterPayViewWithRoleId:(NSString *)roleID
                     andGoodsId:(NSString *)goodsId
                    andGoodsCnt:(NSString *)goodsCnt
                   andGoodsName:(NSString *)goodsName
                  andTotalMoney:(NSString *)totalMoney
                      andPayDes:(NSString *)payDescription;

@end
