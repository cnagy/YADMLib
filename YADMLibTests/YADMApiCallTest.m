//
// YADMApiCallTest.m
//
// Created by Csongor Nagy on 25/04/14.
// Copyright (c) 2014 Csongor Nagy. All rights reserved.
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

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "YADMApiCall.h"

@interface YADMApiCallTest : XCTestCase <YADMApiCallDelegate>

@property (nonatomic, strong) YADMApiCall       *call;
@property (nonatomic, strong) NSURL             *url;
@property (nonatomic, strong) NSDictionary      *params;

@end

@implementation YADMApiCallTest

- (void)setUp
{
    [super setUp];
    
    self.url = [[NSURL alloc] initWithString:@""];
    self.params = @{@"os"              : [[UIDevice currentDevice] systemName],
                    @"os_version"      : [[UIDevice currentDevice] systemVersion],
                    @"device_model"    : [[UIDevice currentDevice] model],
                    };
}

- (void)tearDown
{
    self.call = nil;
    self.url = nil;
    self.params = nil;
    
    [super tearDown];
}

- (void)testALApiCallInstance
{
    self.call = nil;
    XCTAssertNil(self.call, @"Expected the ALApiCall to be not allocated");
    
    self.call = [YADMApiCall requestWith:self.url
                                  method:@"GET"
                                  params:self.params
                                 headers:nil
                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                 timeout:30
                                delegate:self
                        startImmediately:NO];
    
    XCTAssertNotNil(self.call, @"Expected the ALApiCall to be allocated");
    self.call = nil;
}

- (void)testALApiCallDelegateSuccessCallback
{
    self.call = [YADMApiCall requestWith:self.url
                                  method:@"GET"
                                  params:self.params
                                 headers:nil
                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                 timeout:30
                                delegate:self
                        startImmediately:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.call performSelector:@selector(invokeDidFinishedWithResult:) withObject:nil];
#pragma clang diagnostic pop
}

- (void)testALApiCallDelegateErrorCallback
{
    self.call = [YADMApiCall requestWith:self.url
                                  method:@"GET"
                                  params:self.params
                                 headers:nil
                             cachePolicy:NSURLRequestReloadIgnoringCacheData
                                 timeout:30
                                delegate:self
                        startImmediately:NO];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [self.call performSelector:@selector(invokeDidFailedWithError:) withObject:nil];
#pragma clang diagnostic pop
}



#pragma mark - ALApiCallDelegate Methods

- (void)apiCall:(YADMApiCall*)call didFinishedWithResult:(YADMApiCallResult*)callResult
{
    XCTAssertEqualObjects(self.call, call, @"Expected same objects");
}

- (void)apiCall:(YADMApiCall*)call didFailedWithError:(NSError*)error
{
    XCTAssertEqualObjects(self.call, call, @"Expected same objects");
}

@end
