//
//  D9Authorize.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-6-3.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "D9Request.h"
#import "D9LoginDialog.h"

@class D9Authorize;

@protocol D9AuthorizeDelegate <NSObject>


@end

@interface D9Authorize : NSObject <D9LoginDialogDelegate, D9RequestDelegate> {
    D9Request *request;
}

@end
