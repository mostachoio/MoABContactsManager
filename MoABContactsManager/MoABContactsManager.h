//
//  MoABContactsManager.h
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>
#import "MoContact.h"

@interface MoABContactsManager : NSObject

+ (instancetype)sharedManager;


- (void)contacts:(void(^)(ABAuthorizationStatus authorizationStatus, NSArray *contacts))contactsBlock;

@end
