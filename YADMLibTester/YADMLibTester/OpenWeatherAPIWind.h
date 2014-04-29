//
//  OpenWeatherAPIWind.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPIWind <NSObject>
@end

@interface OpenWeatherAPIWind : YADMJSONApiModel <OpenWeatherAPIWind>

@property (nonatomic, strong) NSNumber      *speed;
@property (nonatomic, strong) NSNumber      *gust;
@property (nonatomic, strong) NSNumber      *deg;

@end
