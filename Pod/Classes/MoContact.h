//
//  MoContact.h
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/9/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface MoContact : NSObject

@property (nonatomic) NSInteger contactId;

@property (strong, nonatomic) NSString *firstName;

@property (strong, nonatomic) NSString *firstNamePhonetic;

@property (strong, nonatomic) NSString *lastName;

@property (strong, nonatomic) NSString *lastNamePhonetic;

@property (strong, nonatomic) NSString *middleName;

@property (strong, nonatomic) NSString *middleNamePhonetic;

@property (strong, nonatomic) NSString *prefix;

@property (strong, nonatomic) NSString *suffix;

@property (strong, nonatomic) NSString *fullName;

@property (strong, nonatomic) NSArray *phones;

@property (strong, nonatomic) NSArray *emails;

@property (strong, nonatomic) NSString *nickName;

@property (strong, nonatomic) NSString *company;

@property (strong, nonatomic) NSString *jobTitle;

@property (strong, nonatomic) NSString *department;

@property (strong, nonatomic) NSDate *birthday;

@property (strong, nonatomic) UIImage *thumbnailProfilePicture;

@property (strong, nonatomic) UIImage *originalProfilePicture;

@property (strong, nonatomic) NSString *note;

@property (strong, nonatomic) NSDate *createdAt;

@property (strong, nonatomic) NSDate *updatedAt;

- (NSDictionary *)asDictionary;

@end
