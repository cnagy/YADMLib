//
//  OpenWeatherAPIWeather.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPIWeather <NSObject>
@end

@interface OpenWeatherAPIWeather : YADMJSONApiModel <OpenWeatherAPIWeather>

@property (nonatomic, strong) NSNumber      *id;
@property (nonatomic, strong) NSString      *main;
@property (nonatomic, strong) NSString      *Description;
@property (nonatomic, strong) NSString      *icon;

@end
