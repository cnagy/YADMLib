//
// YADMApiCall.m
//
// Created by Csongor Nagy on 15/04/14.
// Copyright (c) 2014 Csongor Nagy
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "YADMApiCall.h"

@interface YADMApiCall () <NSURLConnectionDelegate, NSURLConnectionDataDelegate>

@property (nonatomic, strong) NSURL                             *url;
@property (nonatomic, strong) NSString                          *method;
@property (nonatomic, strong) NSDictionary                      *params;
@property (nonatomic, strong) NSDictionary                      *headers;
@property (nonatomic, assign) NSURLRequestCachePolicy           policy;
@property (nonatomic, assign) NSTimeInterval                    timeout;
@property (nonatomic, readwrite) NSObject<YADMApiCallDelegate>  *delegate;
@property (nonatomic, strong) NSURLConnection                   *connection;
@property (nonatomic, assign) BOOL                              startImmediately;

@end



@implementation YADMApiCall

#pragma mark - Class Methods

+ (instancetype)requestWith:(NSURL*)url
                     method:(NSString*)method
                     params:(NSDictionary*)params
                    headers:(NSDictionary*)headers
                cachePolicy:(NSURLRequestCachePolicy)policy
                    timeout:(NSTimeInterval)timeout
                   delegate:(id<YADMApiCallDelegate>)delegate
           startImmediately:(BOOL)startImmediately
{
    
    return [[YADMApiCall alloc] initWithURL:url
                                   method:method
                                   params:params
                                  headers:headers
                              cachePolicy:policy
                                  timeout:timeout
                                 delegate:(id<YADMApiCallDelegate>)delegate
                         startImmediately:startImmediately];
}

- (void)start
{
    NSString *uRLString = [NSString stringWithFormat:@"%@?%@", [self.url absoluteString] , [self urlQueryString:self.params]];
    NSURL *requestURL = [NSURL URLWithString:uRLString];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:requestURL
                                                           cachePolicy:self.policy
                                                       timeoutInterval:self.timeout];
    
    [request setHTTPMethod:self.method];
    
    NSArray *keys = [self.headers allKeys];
    for (NSString *key in keys)
    {
        NSString *value = [self.headers objectForKey:key];
        [request addValue:value forHTTPHeaderField:key];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
         {
             NSDictionary *headers = [(NSHTTPURLResponse*)response allHeaderFields];
             NSString *contentType = [headers objectForKey:@"Content-Type"];
             
             if(error == nil &&
                contentType &&
                [contentType isEqualToString:@"application/json; charset=utf-8"])
             {
                 YADMApiCallResult *callResult = [[YADMApiCallResult alloc] init];
                 callResult.httpResponse = response;
                 callResult.responseData = data;
                 
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self invokeDidFinishedWithResult:callResult];
                 });
             }
             else
             {
                 dispatch_async(dispatch_get_main_queue(), ^{
                     [self invokeDidFailedWithError:error];
                 });
             }
         }];
    });
}



#pragma mark - Instance Methods

- (instancetype)initWithURL:(NSURL*)url
                     method:(NSString*)method
                     params:(NSDictionary*)params
                    headers:(NSDictionary*)headers
                cachePolicy:(NSURLRequestCachePolicy)policy
                    timeout:(NSTimeInterval)timeout
                   delegate:(id<YADMApiCallDelegate>)delegate
           startImmediately:(BOOL)startImmediately
{
    self = [super init];
    if(self)
    {
        self.url = url;
        self.method = method;
        self.params = [[NSDictionary alloc] initWithDictionary:params];
        self.headers = [[NSDictionary alloc] initWithDictionary:headers];
        self.policy = policy;
        self.timeout = timeout;
        self.delegate = delegate;
        
        self.startImmediately = startImmediately;
        
        if (self.startImmediately)
        {
            [self start];
        }
    }
    return self;
}

- (void)dealloc
{
    [self.connection cancel];
    self.connection = nil;
}

- (void)invokeDidFailedWithError:(NSError*)error
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(apiCall:didFailedWithError:)])
    {
        [self.delegate apiCall:self didFailedWithError:error];
    }
}

- (void)invokeDidFinishedWithResult:(YADMApiCallResult *)result
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(apiCall:didFinishedWithResult:)])
    {
        [self.delegate apiCall:self didFinishedWithResult:result];
    }
}

- (NSString*)urlQueryString:(NSDictionary*)params
{
    NSMutableArray *parts = [NSMutableArray array];
    
    for (id key in params)
    {
        id value = [params objectForKey: key];
        NSString *part = [NSString stringWithFormat: @"%@=%@", [self urlEncodedString:key], [self urlEncodedString:([value isKindOfClass:[NSNumber class]] ? [value stringValue] : value)]];
        [parts addObject: part];
    }

    return [parts componentsJoinedByString: @"&"];
}

- (NSString*)urlEncodedString:(id)object
{
    NSString *string = [object description];
    return [string stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding];
}

@end
