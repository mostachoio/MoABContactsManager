//
//  MoContactSerializer.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/10/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoContactSerializer.h"
#import <objc/runtime.h>
#import "MoContact.h"

@interface MoContactSerializer ()

@end

@implementation MoContactSerializer

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static MoContactSerializer *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        
    }
    
    return self;
}

#pragma mark - Publics

- (NSDictionary *)serializeContact:(MoContact *)contact
{
    
    NSMutableDictionary *result = [NSMutableDictionary dictionary];
    
    id ContactClass = objc_getClass([NSStringFromClass([contact class]) UTF8String]);
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(ContactClass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        NSString *varName = [NSString stringWithUTF8String:property_getName(property)];
        
        NSString *varKey = [self camelCaseStringToUnderscore:varName];
        if (_customKeyMapper && _customKeyMapper[varName]) {
            varKey = _customKeyMapper[varName];
        }
        
        id varValue = [contact valueForKey:varName];
        
        if (varValue) {
            [result setObject:varValue forKey:varKey];
        }
        
    }
    
    return result;
    
}

#pragma mark - Internals

- (NSString *)camelCaseStringToUnderscore:(NSString *)camelCaseString
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(?<=[a-z])([A-Z])|([A-Z])(?=[a-z])" options:0 error:nil];
    NSString *underscoreString = [[regex stringByReplacingMatchesInString:camelCaseString options:0 range:NSMakeRange(0, camelCaseString.length) withTemplate:@"_$1$2"] lowercaseString];
    return underscoreString;
}

@end
