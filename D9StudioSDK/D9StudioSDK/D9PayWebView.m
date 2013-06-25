//
//  D9PayWebView.m
//  D9StudioSDK
//
//  Created by zhu junjie on 13-6-8.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9PayWebView.h"
#import <QuartzCore/QuartzCore.h>
#import "D9SDKGlobal.h"

@interface D9PayWebView (Private)

- (void)bounceOutAnimationStopped;
- (void)bounceInAnimationStopped;
- (void)bounceNormalAnimationStopped;
- (void)allAnimationsStopped;

- (UIInterfaceOrientation)currentOrientation;
- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation;
- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation;
- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation;

- (void)addObservers;
- (void)removeObservers;

@end

@implementation D9PayWebView


#pragma mark - D9PayView Life Circle

- (id)init
{
    if (self = [super initWithFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)])
    {
        NSLog(@"Land Scape:width:[%f], height[%f]", kD9ScreenHeight, kD9ScreenWidth);
        // background settings
        [self setBackgroundColor:[UIColor clearColor]];
        [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
        
        // add the panel view
        panelView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kD9ScreenHeight - 20, kD9ScreenWidth - 20)];
        [panelView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.55]];
        [[panelView layer] setMasksToBounds:NO]; // very important
        [[panelView layer] setCornerRadius:10.0];
        [self addSubview:panelView];
        
        // add the conainer view
        containerView = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
        [[containerView layer] setBorderColor:[UIColor colorWithRed:0. green:0. blue:0. alpha:0.7].CGColor];
        [[containerView layer] setBorderWidth:1.0];
        
        
        // add the web view
        webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
		[webView setDelegate:self];
		[containerView addSubview:webView];
        
        [panelView addSubview:containerView];
        
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView setCenter:CGPointMake(kD9ScreenHeight * 0.5, kD9ScreenWidth * 0.5)];
        [self addSubview:indicatorView];
    }
    return self;
}

- (void)dealloc
{
    [panelView release], panelView = nil;
    [containerView release], containerView = nil;
    [webView release], webView = nil;
    [indicatorView release], indicatorView = nil;
    
    [super dealloc];
}

#pragma mark Actions

- (void)onCloseButtonTouched:(id)sender
{
    [self closePayView:YES];
}

#pragma mark Orientations

- (UIInterfaceOrientation)currentOrientation
{
    return [UIApplication sharedApplication].statusBarOrientation;
}

- (void)sizeToFitOrientation:(UIInterfaceOrientation)orientation
{
    [self setTransform:CGAffineTransformIdentity];
    
    if (UIInterfaceOrientationIsLandscape(orientation))
    {
        NSLog(@"Land Scape:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        [self setFrame:CGRectMake(0, 0, kD9ScreenHeight, kD9ScreenWidth)];
        [panelView setFrame:CGRectMake(10, 10, kD9ScreenHeight - 20, kD9ScreenWidth - 20)];
        [containerView setFrame:CGRectMake(10, 10, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
        [webView setFrame:CGRectMake(0, 0, kD9ScreenHeight - 40, kD9ScreenWidth - 40)];
        [indicatorView setCenter:CGPointMake(kD9ScreenHeight * 0.5, kD9ScreenWidth * 0.5)];
    }
    else
    {
        NSLog(@"Portain Scape:width:[%f], height[%f]", kD9ScreenWidth, kD9ScreenHeight);
        [self setFrame:CGRectMake(0, 0, kD9ScreenWidth, kD9ScreenHeight)];
        [panelView setFrame:CGRectMake(10, 10, kD9ScreenWidth - 20, kD9ScreenHeight - 20)];
        [containerView setFrame:CGRectMake(10, 10, kD9ScreenWidth - 40, kD9ScreenHeight - 40)];
        [webView setFrame:CGRectMake(0, 0, kD9ScreenWidth - 40, kD9ScreenHeight - 40)];
        [indicatorView setCenter:CGPointMake(kD9ScreenWidth * 0.5, kD9ScreenHeight * 0.5)];
    }
    
    [self setCenter:CGPointMake(kD9ScreenWidth * 0.5, kD9ScreenHeight * 0.5)];
    
    [self setTransform:[self transformForOrientation:orientation]];
    
    previousOrientation = orientation;
}

- (CGAffineTransform)transformForOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == UIInterfaceOrientationLandscapeLeft)
    {
		return CGAffineTransformMakeRotation(-M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationLandscapeRight)
    {
		return CGAffineTransformMakeRotation(M_PI / 2);
	}
    else if (orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
		return CGAffineTransformMakeRotation(-M_PI);
	}
    else
    {
		return CGAffineTransformIdentity;
	}
}

- (BOOL)shouldRotateToOrientation:(UIInterfaceOrientation)orientation
{
	if (orientation == previousOrientation)
    {
		return NO;
	}
    else
    {
		return orientation == UIInterfaceOrientationLandscapeLeft
		|| orientation == UIInterfaceOrientationLandscapeRight
		|| orientation == UIInterfaceOrientationPortrait
		|| orientation == UIInterfaceOrientationPortraitUpsideDown;
	}
    return YES;
}

#pragma mark Obeservers

- (void)addObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(deviceOrientationDidChange:)
												 name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}

- (void)removeObservers
{
	[[NSNotificationCenter defaultCenter] removeObserver:self
													name:@"UIDeviceOrientationDidChangeNotification" object:nil];
}


#pragma mark Animations

- (void)bounceOutAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
	[UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceInAnimationStopped)];
    [panelView setAlpha:0.8];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9)];
	[UIView commitAnimations];
}

- (void)bounceInAnimationStopped
{
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.13];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDidStopSelector:@selector(bounceNormalAnimationStopped)];
    [panelView setAlpha:1.0];
	[panelView setTransform:CGAffineTransformScale(CGAffineTransformIdentity, 1.0, 1.0)];
	[UIView commitAnimations];
}

- (void)bounceNormalAnimationStopped
{
    [self allAnimationsStopped];
}

- (void)allAnimationsStopped
{
    // nothing shall be done here
}

#pragma mark Dismiss

- (void)hideAndCleanUp
{
    [self removeObservers];
	[self removeFromSuperview];
}

#pragma mark - D9PayView Public Methods

- (void)loadRequestWithURL:(NSURL *)url
{
    NSURLRequest *request =[NSURLRequest requestWithURL:url
                                            cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                        timeoutInterval:60.0];
    [webView loadRequest:request];
}

- (void)showPayView:(BOOL)animated
{
    [self sizeToFitOrientation:[self currentOrientation]];
    
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
	if (!window)
    {
		window = [[UIApplication sharedApplication].windows objectAtIndex:0];
	}
  	[window addSubview:self];
    [window bringSubviewToFront:self];
    if (window.rootViewController.view) {
        [window.rootViewController.view addSubview:self];
        [window.rootViewController.view bringSubviewToFront:self];
    }
    
    if (animated)
    {
        [panelView setAlpha:0];
        CGAffineTransform transform = CGAffineTransformIdentity;
        [panelView setTransform:CGAffineTransformScale(transform, 0.3, 0.3)];
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(bounceOutAnimationStopped)];
        [panelView setAlpha:0.5];
        [panelView setTransform:CGAffineTransformScale(transform, 1.1, 1.1)];
        [UIView commitAnimations];
    }
    else
    {
        [self allAnimationsStopped];
    }
    
    [self addObservers];
}

- (void)closePayView:(BOOL)animated
{
	if (animated)
    {
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:0.3];
		[UIView setAnimationDelegate:self];
		[UIView setAnimationDidStopSelector:@selector(hideAndCleanUp)];
		[self setAlpha:0];
		[UIView commitAnimations];
	}
    [self hideAndCleanUp];
}

#pragma mark - UIDeviceOrientationDidChangeNotification Methods

- (void)deviceOrientationDidChange:(id)object
{
	UIInterfaceOrientation orientation = [self currentOrientation];
	if ([self shouldRotateToOrientation:orientation])
    {
        NSTimeInterval duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
        
		[UIView beginAnimations:nil context:nil];
		[UIView setAnimationDuration:duration];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[self sizeToFitOrientation:orientation];
		[UIView commitAnimations];
	}
}

#pragma mark - UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)aWebView
{
	[indicatorView startAnimating];
}

- (void)webViewDidFinishLoad:(UIWebView *)aWebView
{
	[indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)aWebView didFailLoadWithError:(NSError *)error
{
    [indicatorView stopAnimating];
    NSLog(@"WebView Did Fail Load With Error:%@", [error description]);
    [self closePayView:NO];
}

//- (BOOL)webView:(UIWebView *)aWebView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
//{
//    NSRange range = [request.URL.absoluteString rangeOfString:@"code="];
//    
//    if (range.location != NSNotFound)
//    {
//        NSString *code = [request.URL.absoluteString substringFromIndex:range.location + range.length];
//        
//        if ([delegate respondsToSelector:@selector(authorizeWebView:didReceiveAuthorizeCode:)])
//        {
//            [delegate authorizeWebView:self didReceiveAuthorizeCode:code];
//        }
//    }
//
//    return YES;
//}
@end
