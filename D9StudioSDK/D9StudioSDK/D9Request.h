//
//  D9Request.h
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-6-3.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
    kD9RequestPostDataTypeNone,
    kD9RequestPostDataTypeNormal,   // post, "user=name&pwd=psd"
    kD9RequestPostDataTypeMulti,    // extend method, upload images & files
}D9RequestPostDataType;

@class D9Request;
@protocol D9RequestDelegate <NSObject>

@optional
- (void) request:(D9Request *)request didReceiveResponse:(NSURLResponse *)response;
- (void) request:(D9Request *)request didReceiveRawData:(NSData *)data;
- (void) request:(D9Request *)request didFailWithError:(NSError *)error;
- (void) request:(D9Request *)request didFinishLoadingWithResult:(id)result;

@end

@interface D9Request : NSObject
{
    NSString    *url;
    NSString    *httpMethod;
    NSDictionary    *params;
    D9RequestPostDataType   postDataType;
    NSDictionary    *httpHeaderFields;
    
    NSURLConnection *connection;
    NSMutableData   *responseData;
    
    id<D9RequestDelegate>   delegate;
}

@property (nonatomic, retain) NSString  *url;
@property (nonatomic, retain) NSString  *httpMethod;
@property (nonatomic, retain) NSDictionary  *params;
@property D9RequestPostDataType postDataType;
@property (nonatomic, retain) NSDictionary  *httpHeaderFields;
@property (nonatomic, assign) id<D9RequestDelegate> delegate;

+ (D9Request *) requestWithURL:(NSString *) url
                    httpMethod:(NSString *) httpMethod
                        params:(NSDictionary *) params
                  postDataType:(D9RequestPostDataType) postDataType
              httpHeaderFields:(NSDictionary *) httpHeaderFields
                      delegate:(id<D9RequestDelegate>)delegate;

+ (D9Request *) requestWithAccessToken:(NSString *) accessToken
                                   url:(NSString *) url
                            httpMethod:(NSString *)httpMethod
                                params:(NSDictionary *) params
                          postDataType:(D9RequestPostDataType) postDataType
                      httpHeaderFields:(NSDictionary *) httpHeaderFields
                              delegate:(id<D9RequestDelegate>) delegate;

+ (NSString *) serializeURL:(NSString *) baseURL
                     params:(NSDictionary *) params
                 httpMethod:(NSString *)httpMethod;

- (void) connect;
- (void) disconnect;
@end
