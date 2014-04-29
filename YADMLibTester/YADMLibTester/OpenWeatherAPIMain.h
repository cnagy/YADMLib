//
//  OpenWeatherAPIMain.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPIMain <NSObject>
@end

@interface OpenWeatherAPIMain : YADMJSONApiModel <OpenWeatherAPIMain>

@property (nonatomic, strong) NSNumber      *temp;
@property (nonatomic, strong) NSNumber      *humidity;
@property (nonatomic, strong) NSNumber      *pressure;
@property (nonatomic, strong) NSNumber      *temp_min;
@property (nonatomic, strong) NSNumber      *temp_max;

@end
