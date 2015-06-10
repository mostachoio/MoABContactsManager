//
//  MoABContactsManager.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoABContactsManager.h"


@interface MoABContactsManager ()

@property (nonatomic) ABAddressBookRef addressBook;

@end

@implementation MoABContactsManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static MoABContactsManager *sharedInstance;
    
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    if (!(self == [super init])) return nil;
    
    _addressBook =ABAddressBookCreateWithOptions(NULL, nil);
    
    return self;
}

#pragma mark - Publics

- (void)contacts:(void (^)(ABAuthorizationStatus, NSArray *))contactsBlock
{
    ABAuthorizationStatus abAuthStatus = ABAddressBookGetAuthorizationStatus();
    
    switch (abAuthStatus) {
            
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            if (contactsBlock) {
                contactsBlock(abAuthStatus, nil);
            }
            break;
            
        case kABAuthorizationStatusNotDetermined:
        {       // Ask user for permissions
            
            ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self loadContactsFromAddressBookWithCompletionBlock:contactsBlock];
                }else if (contactsBlock){
                    contactsBlock(kABAuthorizationStatusDenied, nil);
                }
            });
            
            break;
        }
        case kABAuthorizationStatusAuthorized:
        {
            [self loadContactsFromAddressBookWithCompletionBlock:contactsBlock];
            break;
        }
    }
    
}

#pragma mark - Internals -

- (void)loadContactsFromAddressBookWithCompletionBlock:(void(^)(ABAuthorizationStatus, NSArray *))contactsBlock
{
    
    NSArray *contactsFromAB = (__bridge NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBook);
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    for (id contactObj in contactsFromAB) {
        
        ABRecordRef contactRecord = (__bridge ABRecordRef)contactObj;
        
        MoContact *contact = [[MoContact alloc] init];
        
        ABRecordID contactId = ABRecordGetRecordID(contactRecord);
        
        [contact setContactId:contactId];
        
        [contact setFirstName:[self objectFromProperty:kABPersonFirstNameProperty ofContact:contactRecord]];
        [contact setFirstNamePhonetic:[self objectFromProperty:kABPersonFirstNamePhoneticProperty ofContact:contactRecord]];
        
        [contact setLastName:[self objectFromProperty:kABPersonLastNameProperty ofContact:contactRecord]];
        [contact setLastNamePhonetic:[self objectFromProperty:kABPersonLastNamePhoneticProperty ofContact:contactRecord]];
        
        [contact setMiddleName:[self objectFromProperty:kABPersonMiddleNameProperty ofContact:contactRecord]];
        [contact setMiddleNamePhonetic:[self objectFromProperty:kABPersonMiddleNamePhoneticProperty ofContact:contactRecord]];
        
        [contact setPrefix:[self objectFromProperty:kABPersonPrefixProperty ofContact:contactRecord]];
        
        [contact setSuffix:[self objectFromProperty:kABPersonSuffixProperty ofContact:contactRecord]];
        
        [self setFullNameForContact:contact];
        
        [contact setNickName:[self objectFromProperty:kABPersonNicknameProperty ofContact:contactRecord]];
        
        [contact setCompany:[self objectFromProperty:kABPersonOrganizationProperty ofContact:contactRecord]];
        
        [contact setJobTitle:[self objectFromProperty:kABPersonJobTitleProperty ofContact:contactRecord]];
        
        [contact setDepartment:[self objectFromProperty:kABPersonDepartmentProperty ofContact:contactRecord]];
        
        [contact setBirthday:[self objectFromProperty:kABPersonBirthdayProperty ofContact:contactRecord]];
        
        NSData *thumImageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(contactRecord, kABPersonImageFormatThumbnail);
        if (thumImageData) {
            [contact setThumbnailProfilePicture:[UIImage imageWithData:thumImageData]];
        }
        
        NSData *originalImageData = (__bridge NSData*)ABPersonCopyImageDataWithFormat(contactRecord, kABPersonImageFormatOriginalSize);
        if (originalImageData) {
            [contact setOriginalProfilePicture:[UIImage imageWithData:originalImageData]];
        }
        
        [contact setNote:[self objectFromProperty:kABPersonNoteProperty ofContact:contactRecord]];
        
        [contact setCreatedAt:[self objectFromProperty:kABPersonCreationDateProperty ofContact:contactRecord]];
        
        [contact setUpdatedAt:[self objectFromProperty:kABPersonModificationDateProperty ofContact:contactRecord]];
        
        [contacts addObject:contact];
        
    }
    
    if (contactsBlock) {
        contactsBlock(kABAuthorizationStatusAuthorized, contacts);
    }
    
}

#pragma mark - Utils

- (id)objectFromProperty:(ABPropertyID)property ofContact:(ABRecordRef)contact
{
    CFTypeRef valueRef = ABRecordCopyValue(contact, property);
    return valueRef ? (__bridge id)valueRef : nil;
}

- (void)setFullNameForContact:(MoContact *)contact
{
    
    NSArray *keys = @[@"prefix", @"firstName", @"middleName", @"lastName", @"suffix"];
    NSMutableString *fullName = [NSMutableString stringWithString:@""];
    
    for (NSString *key in keys) {
        
        NSString *value = [contact valueForKey:key];
        if (value) {
            [fullName appendString:[fullName length] > 0 ? @" " : @""];
            [fullName appendString:value];
        }
    }
    
    [contact setFullName:fullName];
    
}

@end
