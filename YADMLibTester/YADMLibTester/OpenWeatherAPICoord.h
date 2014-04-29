//
//  OpenWeatherAPICoord.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPICoord <NSObject>
@end

@interface OpenWeatherAPICoord : YADMJSONApiModel <OpenWeatherAPICoord>

@property (nonatomic, strong) NSNumber      *lon;
@property (nonatomic, strong) NSNumber      *lat;

@end
