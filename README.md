# YADMLib

YADMLib is a lightweight network library, with JSON to data model parsing capability for Objective C.

## Requirements

* ARC only; iOS 6.1+

## Install

#### 1) Source files

1. Download the YADMLib repository as a [zip file](https://github.com/cnagy/YADMLib/archive/master.zip) or clone it
2. Copy the YADMLib sub-folder into your Xcode project

#### 2) via Cocoa pods

In your project's **Podfile** add the YADMLib pod:

```ruby
pod 'YADMLib'
```
If you want to read more about CocoaPods, have a look at [this short tutorial](http://www.raywenderlich.com/12139/introduction-to-cocoapods).

## Usage

Let's to get some JSON from [Openweather](http://api.openweathermap.org/data/2.5/weather?q=Berlin,de) and map it in a `OpenWeatherAPI` model.

Our basic `OpenWeatherAPI` model will look like

```objective-c
#import "YADMJSONApiModel.h"

@protocol OpenWeatherAPI <NSObject>
@end

@interface OpenWeatherAPI : YADMJSONApiModel <OpenWeatherAPI>

@property (nonatomic, strong) NSString                          *base;
@property (nonatomic, strong) NSNumber                          *dt;
@property (nonatomic, strong) NSNumber                          *id;
@property (nonatomic, strong) NSString                          *name;
@property (nonatomic, strong) NSNumber                          *cod;

@end
```

Now let's call the Openweather API through the `OpenWeatherAPI` class in a controller:

```objective-c
#import "YADMJSONApiModel.h"

@interface ViewController ()
@property (nonatomic, strong) OpenWeatherAPI    *weather;
@end

@implementation ViewController

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
                                      if (!error && strongSelf.weather.result)
                                      {
                                          [strongSelf testTimeLoaded];
                                      }
                                  }];
}

- (void)testTimeLoaded
{
    NSLog(@"City: %@", self.weather.name);
}

@end
```

