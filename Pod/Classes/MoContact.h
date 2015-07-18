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

/*!
 @abstract Returns the contact ID.
 */
@property (nonatomic) NSInteger contactId;

/*!
 @abstract Contact's first name.
 */
@property (strong, nonatomic) NSString *firstName;

/*!
 @abstract Returns the phonetic of contact's first name.
 */
@property (strong, nonatomic) NSString *firstNamePhonetic;

/*!
 @abstract Contact's last name.
 */
@property (strong, nonatomic) NSString *lastName;

/*!
 @abstract Returns the phonetic of contact's last name.
 */
@property (strong, nonatomic) NSString *lastNamePhonetic;

/*!
 @abstract Contact's middle name.
 */
@property (strong, nonatomic) NSString *middleName;

/*!
 @abstract Returns the phonetic of contact's middle name.
 */
@property (strong, nonatomic) NSString *middleNamePhonetic;

/*!
 @abstract Contact's the prefix of the name.
 */
@property (strong, nonatomic) NSString *prefix;

/*!
 @abstract Returns the suffix of contact's the name.
 */
@property (strong, nonatomic) NSString *suffix;

/*!
 @abstract Contact's fullname ([prefix] [firstName] [middleName] [lastName] [suffix]).
 */
@property (strong, nonatomic) NSString *fullName;

/*!
 @abstract Contact's phones. [{label: phone_number}]
 */
@property (strong, nonatomic) NSArray *phones;

/*!
 @abstract Contact's emails. [{label: email}]
 */
@property (strong, nonatomic) NSArray *emails;

/*!
 @abstract Contact's address. [{label: {*address info*}}]
 */
@property (strong, nonatomic) NSArray *addresses;

/*!
 @abstract Contact's nick name.
 */
@property (strong, nonatomic) NSString *nickName;

/*!
 @abstract Contact's company.
 */
@property (strong, nonatomic) NSString *company;

/*!
 @abstract Contact's job title.
 */
@property (strong, nonatomic) NSString *jobTitle;

/*!
 @abstract Contact's department.
 */
@property (strong, nonatomic) NSString *department;

/*!
 @abstract Contact's birthday.
 */
@property (strong, nonatomic) NSDate *birthday;

/*!
 @abstract Thumbnail of contact's profile picture.
 */
@property (strong, nonatomic) UIImage *thumbnailProfilePicture;

/*!
 @abstract Original contact's profile picture.
 */
@property (strong, nonatomic) UIImage *originalProfilePicture;

/*!
 @abstract Notes.
 */
@property (strong, nonatomic) NSString *note;

/*!
 @abstract Contact's creation date.
 */
@property (strong, nonatomic) NSDate *createdAt;

/*!
 @abstract Contact's update date.
 */
@property (strong, nonatomic) NSDate *updatedAt;

/*!
 @abstract Contact's emails values list. [email1, email2...]
 */
@property (strong, nonatomic, readonly) NSArray *emailsValues;

/*!
 @abstract Contact's phones values. [phone1, phone2...]
 */
@property (strong, nonatomic, readonly) NSArray *phonesValues;

- (NSDictionary *)asDictionary;

@end
