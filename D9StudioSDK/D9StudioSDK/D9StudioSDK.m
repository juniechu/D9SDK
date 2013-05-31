//
//  D9StudioSDK.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-5-28.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9StudioSDK.h"
#import "D9LoginDialog.h"

@implementation D9StudioSDK

- (void) login
{
    NSLog(@"D9Studio login");
    [[D9LoginDialog alloc] init];
}

@end
