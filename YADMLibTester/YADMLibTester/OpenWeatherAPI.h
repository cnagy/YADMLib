//
//  OpenWeatherAPI.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"
#import "OpenWeatherAPICoord.h"
#import "OpenWeatherAPISys.h"
#import "OpenWeatherAPIWeather.h"
#import "OpenWeatherAPIMain.h"
#import "OpenWeatherAPIWind.h"
#import "OpenWeatherAPIClouds.h"

@protocol OpenWeatherAPI <NSObject>
@end

@interface OpenWeatherAPI : YADMJSONApiModel <OpenWeatherAPI>

@property (nonatomic, strong) OpenWeatherAPICoord               *coord;
@property (nonatomic, strong) OpenWeatherAPISys                 *sys;
@property (nonatomic, strong) NSArray<OpenWeatherAPIWeather>    *weather;
@property (nonatomic, strong) NSString                          *base;
@property (nonatomic, strong) OpenWeatherAPIMain                *main;
@property (nonatomic, strong) OpenWeatherAPIWind                *wind;
@property (nonatomic, strong) OpenWeatherAPIClouds              *clouds;
@property (nonatomic, strong) NSNumber                          *dt;
@property (nonatomic, strong) NSNumber                          *id;
@property (nonatomic, strong) NSString                          *name;
@property (nonatomic, strong) NSNumber                          *cod;

@end
