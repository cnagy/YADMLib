//
//  OpenWeatherAPISys.h
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPISys <NSObject>
@end

@interface OpenWeatherAPISys : YADMJSONApiModel <OpenWeatherAPISys>

@property (nonatomic, strong) NSNumber      *message;
@property (nonatomic, strong) NSString      *country;
@property (nonatomic, strong) NSNumber      *sunrise;
@property (nonatomic, strong) NSNumber      *sunset;

@end
