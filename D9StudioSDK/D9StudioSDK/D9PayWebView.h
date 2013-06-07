//
//  D9PayWebView.h
//  D9StudioSDK
//
//  Created by zhu junjie on 13-6-8.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface D9PayWebView : UIView <UIWebViewDelegate>
{
    UIView *panelView;
    UIView *containerView;
    UIActivityIndicatorView *indicatorView;
    UIWebView *webView;
    
    UIInterfaceOrientation previousOrientation;
    
}

- (void) loadRequestWithURL:(NSURL *)url;
- (void) showPayView:(BOOL) animated;
- (void) closePayView:(BOOL) animated;

@end
