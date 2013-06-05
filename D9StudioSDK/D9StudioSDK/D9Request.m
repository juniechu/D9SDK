//
//  D9Request.m
//  D9StudioSDK
//
//  Created by 朱 俊杰 on 13-6-3.
//  Copyright (c) 2013年 朱 俊杰. All rights reserved.
//

#import "D9Request.h"
#import "D9SDKUtil.h"
#import "JSON.h"
#import "D9SDKGlobal.h"

#import "UIKit/UIImage.h"

#define kD9RequestTimeOutInterval   180.0
#define kD9RequestStringBoundary    @""     // post method & type multi use this boundary

@interface D9Request (Private)

+ (NSString *)stringFromDictionary:(NSDictionary *)dict;
+ (void) appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString;
- (NSMutableData *)postBody;

- (void) handleResponseData:(NSData *)data;
- (id)parseJSONData:(NSData *)data error:(NSError **)error;

- (id) errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo;
- (void) failedWithError:(NSError *) error;

@end

@implementation D9Request

@synthesize url;
@synthesize httpMethod;
@synthesize params;
@synthesize postDataType;
@synthesize httpHeaderFields;
@synthesize delegate;

#pragma mark - D9Request Life Circle

- (void) dealloc
{
    [url release], url = nil;
    [httpMethod release], httpMethod = nil;
    [params release], params = nil;
    [httpHeaderFields release], httpHeaderFields = nil;
    
    [responseData release];
	responseData = nil;
    
    [connection cancel];
    [connection release], connection = nil;
    
    [super dealloc];
}

#pragma mark - D9Request Private Methods

+ (NSString *) stringFromDictionary:(NSDictionary *)dict
{
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString * key in [dict keyEnumerator]) {
        if (!([[dict valueForKey:key] isKindOfClass:[NSString class]])) {
            continue;
        }
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, [[dict objectForKey:key] URLEncodedString]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

+ (void)appendUTF8Body:(NSMutableData *)body dataString:(NSString *)dataString
{
    [body appendData:[dataString dataUsingEncoding:NSUTF8StringEncoding]];
}

- (NSMutableData *)postBody
{
    NSMutableData *body = [NSMutableData data];
    
    if (postDataType == kD9RequestPostDataTypeNormal)
    {
        [D9Request appendUTF8Body:body dataString:[D9Request stringFromDictionary:params]];
    }
    else if (postDataType == kD9RequestPostDataTypeMulti)
    {
        NSString *bodyPrefixString = [NSString stringWithFormat:@"--%@\r\n", kD9RequestStringBoundary];
		NSString *bodySuffixString = [NSString stringWithFormat:@"\r\n--%@--\r\n", kD9RequestStringBoundary];
        
        NSMutableDictionary *dataDictionary = [NSMutableDictionary dictionary];
        
        [D9Request appendUTF8Body:body dataString:bodyPrefixString];
        
        for (id key in [params keyEnumerator])
		{
			if (([[params valueForKey:key] isKindOfClass:[UIImage class]]) || ([[params valueForKey:key] isKindOfClass:[NSData class]]))
			{
				[dataDictionary setObject:[params valueForKey:key] forKey:key];
				continue;
			}
			
			[D9Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n%@\r\n", key, [params valueForKey:key]]];
			[D9Request appendUTF8Body:body dataString:bodyPrefixString];
		}
		
		if ([dataDictionary count] > 0)
		{
			for (id key in dataDictionary)
			{
				NSObject *dataParam = [dataDictionary valueForKey:key];
				
				if ([dataParam isKindOfClass:[UIImage class]])
				{
					NSData* imageData = UIImagePNGRepresentation((UIImage *)dataParam);
					[D9Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"file.png\"\r\n", key]];
					[D9Request appendUTF8Body:body dataString:@"Content-Type: image/png\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:imageData];
				}
				else if ([dataParam isKindOfClass:[NSData class]])
				{
					[D9Request appendUTF8Body:body dataString:[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n", key]];
					[D9Request appendUTF8Body:body dataString:@"Content-Type: content/unknown\r\nContent-Transfer-Encoding: binary\r\n\r\n"];
					[body appendData:(NSData*)dataParam];
				}
				[D9Request appendUTF8Body:body dataString:bodySuffixString];
			}
		}
    }
    
    return body;
}

- (void)handleResponseData:(NSData *)data
{
    if ([delegate respondsToSelector:@selector(request:didReceiveRawData:)])
    {
        [delegate request:self didReceiveRawData:data];
    }
	
//	NSError* error = nil;
//	id result = [self parseJSONData:data error:&error];
//	
//	if (error)
//	{
//		[self failedWithError:error];
//	}
//	else
//	{
//        if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)])
//		{
//            [delegate request:self didFinishLoadingWithResult:(result == nil ? data : result)];
//		}
//	}
    NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    id result = dataString;
    if ([delegate respondsToSelector:@selector(request:didFinishLoadingWithResult:)])
    {
        [delegate request:self didFinishLoadingWithResult:result];
    }
}

- (id)parseJSONData:(NSData *)data error:(NSError **)error
{
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (DEBUG_LOG) {
        NSLog(@"parseJSONData:%@", dataString);
    }
    
    // Parse Json result in the following.
	SBJSON *jsonParser = [[SBJSON alloc] init];
    
	NSError *parseError = nil;
	id result = [jsonParser objectWithString:dataString error:&parseError];
	
	if (parseError)
    {
        if (error != nil)
        {
            *error = [self errorWithCode:kD9ErrorCodeSDK
                                userInfo:[NSDictionary dictionaryWithObject:[NSString stringWithFormat:@"%d", kD9SDKErrorCodeParseError]
                                                                     forKey:kD9SDKErrorCodeKey]];
        }
	}
    
	[dataString release];
	[jsonParser release];
	
    
	if ([result isKindOfClass:[NSDictionary class]])
	{
		if ([result objectForKey:@"error_code"] != nil && [[result objectForKey:@"error_code"] intValue] != 200)
		{
			if (error != nil)
			{
				*error = [self errorWithCode:kD9ErrorCodeInterface userInfo:result];
			}
		}
	}

	return result;
}

- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:kD9SDKErrorDomain code:code userInfo:userInfo];
}

- (void)failedWithError:(NSError *)error
{
	if ([delegate respondsToSelector:@selector(request:didFailWithError:)])
	{
		[delegate request:self didFailWithError:error];
	}
}

#pragma mark - D9Request Public Methods

+ (D9Request *)requestWithURL:(NSString *)url
                   httpMethod:(NSString *)httpMethod
                       params:(NSDictionary *)params
                 postDataType:(D9RequestPostDataType)postDataType
             httpHeaderFields:(NSDictionary *)httpHeaderFields
                     delegate:(id<D9RequestDelegate>)delegate
{
    D9Request *request = [[[D9Request alloc] init] autorelease];
    
    request.url = url;
    request.httpMethod = httpMethod;
    request.params = params;
    request.postDataType = postDataType;
    request.httpHeaderFields = httpHeaderFields;
    request.delegate = delegate;
    
    return request;
}

+ (D9Request *)requestWithAccessToken:(NSString *)accessToken
                                  url:(NSString *)url
                           httpMethod:(NSString *)httpMethod
                               params:(NSDictionary *)params
                         postDataType:(D9RequestPostDataType)postDataType
                     httpHeaderFields:(NSDictionary *)httpHeaderFields
                             delegate:(id<D9RequestDelegate>)delegate
{
    // add access token field
    NSMutableDictionary *mutableParams = [NSMutableDictionary dictionaryWithDictionary:params];
    [mutableParams setObject:accessToken forKey:@"access_token"];
    return [D9Request requestWithURL:url
                          httpMethod:httpMethod
                              params:mutableParams
                        postDataType:postDataType
                    httpHeaderFields:httpHeaderFields
                            delegate:delegate];
}

+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    if (![httpMethod isEqualToString:@"GET"]) {
        return baseURL;
    }
    
    NSURL *parsedURL = [NSURL URLWithString:baseURL];
    NSString *queryPrefix = parsedURL.query ? @"&" : @"?";
    NSString *query = [D9Request stringFromDictionary:params];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}

- (void) connect
{
    NSString *urlString = [D9Request serializeURL:url params:params httpMethod:httpMethod];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:kD9RequestTimeOutInterval];
    [request setHTTPMethod:httpMethod];
    
    if ([httpMethod isEqualToString:@"POST"]) {
        if (postDataType == kD9RequestPostDataTypeMulti) {
            NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", kD9RequestStringBoundary];
            [request setValue:contentType forHTTPHeaderField:@"Content-Type"];
        }
        
        [request setHTTPBody:[self postBody]];
    }
    
    for (NSString *key in [httpHeaderFields keyEnumerator]) {
        [request setValue:[httpHeaderFields objectForKey:key] forHTTPHeaderField:key];
    }
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void) disconnect
{
    [responseData release];
    responseData = nil;
    
    [connection cancel];
    [connection release];
    connection = nil;
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if (DEBUG_LOG) {
        NSLog(@"D9Request:connection didReceiveResponse.");
    }
	responseData = [[NSMutableData alloc] init];
	
	if ([delegate respondsToSelector:@selector(request:didReceiveResponse:)])
    {
		[delegate request:self didReceiveResponse:response];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if (DEBUG_LOG) {
        NSLog(@"D9Request:connection didReceiveData.");
    }
	[responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
				  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
	return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
    if (DEBUG_LOG) {
        NSLog(@"D9Request:connection didFinishLoading.");
    }
	[self handleResponseData:responseData];
    
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
    if (DEBUG_LOG) {
        NSLog(@"D9Request:connection didFailWithError.");
    }
	[self failedWithError:error];
	
	[responseData release];
	responseData = nil;
    
    [connection cancel];
	[connection release];
	connection = nil;
}

@end
