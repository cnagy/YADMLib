//
// YADMJSONToDomainModelParser.m
//
// Created by Csongor Nagy on 15/04/14.
// Copyright (c) 2014 Csongor Nagy
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

#import <objc/message.h>
#import <objc/runtime.h>

#import "YADMJSONToDomainModelParser.h"

#define reservedNames [NSArray arrayWithObjects:@"description", nil]

NSString    * const kYADMDateFormat             = @"dd-MM-yyyy";

@implementation YADMJSONToDomainModelParser

#pragma mark - Class Methods

+ (instancetype)initToParseResult:(id)jsonObject
                          onModel:(NSString*)model
{
    
    return [[YADMJSONToDomainModelParser alloc] initToParseResult:(id)jsonObject
                                                        onModel:model];
}



#pragma mark - Instance Methods

- (instancetype)initToParseResult:(id)jsonObject
                          onModel:(NSString*)model
{
    self = [super init];
    
    if(self)
    {
        if ([[jsonObject class] isSubclassOfClass:[NSArray class]])
        {
            self.result = [self createFromArray:(NSArray*)jsonObject entityName:model];
        }
        else
        {
            self.result = [self createFromDictionary:jsonObject entityName:model];
        }
    }

    return self;
}



- (NSObject*)createFromDictionary:(NSDictionary*)element entityName:(NSString*)entityName
{
    id entity = [[NSClassFromString(entityName) alloc] init];
    [self parseElement:element entity:entity entityName:entityName];
    return entity;
}

- (NSArray*)createFromArray:(NSArray*)elements entityName:(NSString*)entityName
{
    NSMutableArray *result = [NSMutableArray array];
    
    if (entityName)
    {
        for (NSDictionary *element in elements)
        {
            NSObject *entity = [self createFromDictionary:element entityName:entityName];
            if(entity)
            {
                [result addObject:entity];
            }
        }
    }
    
    return result;
}

- (void)parseElement:(NSDictionary*)element entity:(NSObject*)entity entityName:(NSString*)entityName
{
    Class class = [entity class];
    
    [element enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSString *property = key;
        NSString *valueString = obj;
        
        if ([[valueString class] isSubclassOfClass:[NSDictionary class]])
        {
            if ([entity respondsToSelector:NSSelectorFromString(property)])
            {
                NSDictionary *newElement = (NSDictionary *)valueString;
                NSString* propertyType = [self getPropertyType:entity property:property];
                id newEntity = [[NSClassFromString(propertyType) alloc] init];
                [self parseElement:newElement entity:newEntity entityName:propertyType];
                [self addField:property value:newEntity entity:entity];
            }
        }
        else if ([[valueString class] isSubclassOfClass:[NSArray class]])
        {
            if (![entity respondsToSelector:NSSelectorFromString(property)])
            {
                return;
            }
            objc_property_t p = class_getProperty(class, [property UTF8String]);
            const char *attrs = property_getAttributes(p);
            NSString* propertyAttributes = [NSString stringWithUTF8String:attrs];
            
            NSScanner *scanner = [NSScanner scannerWithString:propertyAttributes];
            if ([scanner scanUpToString:@"<" intoString:nil])
            {
                while (![scanner isAtEnd])
                {
                    NSString *protocolName;
                    [scanner scanString:@"<" intoString:NULL];
                    [scanner scanUpToString:@">" intoString: &protocolName];
                    [scanner scanUpToString:@"<" intoString:nil];
                    
                    NSArray *json = (NSArray*)valueString;
                    NSArray *elements = [self createFromArray:json entityName:protocolName];
                    
                    @try
                    {
                        [entity setValue:elements forKey:property];
                    }
                    @catch (NSException *e)
                    {
                        if ([[e name] isEqualToString:NSUndefinedKeyException])
                        {
                            NSLog(@"%@ does not recognize the property \"name\"", property);
                        }
                    }
                    
                    return;
                }
                
                NSArray *json = (NSArray*)valueString;
                @try
                {
                    [entity setValue:json forKey:property];
                }
                @catch (NSException *e)
                {
                    if ([[e name] isEqualToString:NSUndefinedKeyException])
                    {
                        NSLog(@"%@ does not recognize the property \"name\"", [property uppercaseString]);
                    }
                }
            }
            else
            {
                NSArray *json = (NSArray *) valueString;

                @try {
                    [entity setValue:json forKey:property];
                }
                @catch (NSException *ex) {
                    
                }
            }
        }
        else
        {
            [self addField:property value:valueString entity:entity];
        }
    }];
}

- (NSString*)getPropertyType:(NSObject*)entity property:(NSString*)property
{
    if ([reservedNames containsObject:property])
    {
        NSString *uppercase = [[property substringToIndex:1] uppercaseString];
        NSString *lowercase = [[property substringFromIndex:1] lowercaseString];
        property = [uppercase stringByAppendingString:lowercase];
    }
    
    const char *type = property_getAttributes(class_getProperty([entity class], [property UTF8String]));
    NSString *typeString = [NSString stringWithUTF8String:type];
    NSArray *attributes = [typeString componentsSeparatedByString:@","];
    if(attributes.count > 0) {
        NSString * typeAttribute = [attributes objectAtIndex:0];
        NSString * propertyType = [typeAttribute substringFromIndex:1];
        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"@" withString:@""];
        propertyType = [propertyType stringByReplacingOccurrencesOfString:@"\"" withString:@""];
        return propertyType;
    }
    return nil;
}

- (void)addField:(NSString*)property value:(NSString*)valueString entity:(NSObject*)entity
{
    if (![entity respondsToSelector:NSSelectorFromString(property)])
    {
        return;
    }
    
    NSString* propertyType = [self getPropertyType:entity property:property];
    id value = valueString;
    
    if ([propertyType isEqualToString:@"NSNumber"])
    {
        if([valueString respondsToSelector:@selector(doubleValue)])
        {
            value = [NSNumber numberWithDouble:[valueString doubleValue]];
        }
    }
    else if ([propertyType isEqualToString:@"NSDate"])
    {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:kYADMDateFormat];
        value = [dateFormatter dateFromString:valueString];
    }
    else if (NSClassFromString(propertyType) == nil)
    {
        NSLog(@"Property : %@ - has not specified property type", property);
        return;
    }
    
    @try
    {
        [entity setValue:value forKey:property];
    }
    @catch (NSException *e)
    {
        if ([[e name] isEqualToString:NSUndefinedKeyException])
        {
            NSLog(@"%@ does not recognize the property \"name\"", [property uppercaseString]);
        }
    }
}

@end
