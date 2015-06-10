//
//  MoContact.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/9/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoContact.h"
#import "MoContactSerializer.h"

@implementation MoContact

- (NSDictionary *)asDictionary
{
    return [[MoContactSerializer sharedInstance] serializeContact:self];
}

@end
