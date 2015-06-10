//
//  MoContactSerializer.h
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/10/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MoContact;

@interface MoContactSerializer : NSObject

+ (instancetype)sharedInstance;

@property (strong, nonatomic) NSDictionary *customKeyMapper;

- (NSDictionary *)serializeContact:(MoContact *)contact;

@end
