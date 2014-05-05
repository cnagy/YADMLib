//
//  ViewController.m
//  YADMLibTester
//
//  Created by Csongor Nagy on 29/04/14.
//  Copyright (c) 2014 Csongor Nagy. All rights reserved.
//

#import "ViewController.h"

#import "YADMJSONApiModel.h"
#import "OpenWeatherAPI.h"

@interface ViewController ()

@property (nonatomic, strong) OpenWeatherAPI    *weather;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak typeof(self) weakSelf = self;
    
    self.weather = [[OpenWeatherAPI alloc] initWithURL:[NSURL URLWithString:@"http://api.openweathermap.org/data/2.5/weather"]
                                                method:@"GET"
                                                params:@{@"q"       : @"Berlin,de",
                                                         @"units"   : @"metric"}
                                               headers:nil
                                           cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                               timeout:30
                                    andCompletionBlock:^(NSError *error) {
                                        __strong typeof(self) strongSelf = weakSelf;
                                        if (!error)
                                        {
                                            [strongSelf testTimeLoaded];
                                        }
                                    }];
}

- (void)testTimeLoaded
{
    NSLog(@"Base: %@", self.weather.base);
    NSLog(@"Coord/lat: %@", self.weather.coord.lat);
    NSLog(@"Sys/country: %@", self.weather.sys.country);
    NSLog(@"Weather/description: %@", ((OpenWeatherAPIWeather*)[self.weather.weather firstObject]).description);
    NSLog(@"Main/temp: %@", self.weather.main.temp);
    NSLog(@"Wind/speed: %@", self.weather.wind.speed);
    NSLog(@"Clouds/all: %@", self.weather.clouds.all);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
