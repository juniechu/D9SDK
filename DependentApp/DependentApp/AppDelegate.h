//
//  AppDelegate.h
//  DependentApp
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <D9StudioSDK-iOS/D9StudioSDK.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    D9StudioSDK *engine;
}

@property (strong, nonatomic) UIWindow *window;

@end
