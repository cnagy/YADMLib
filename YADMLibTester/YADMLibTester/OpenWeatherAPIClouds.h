//
//  OpenWeatherAPIClouds.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPIClouds <NSObject>
@end

@interface OpenWeatherAPIClouds : YADMJSONApiModel <OpenWeatherAPIClouds>

@property (nonatomic, strong) NSNumber      *all;

@end
