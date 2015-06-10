//
//  MoABContactsManager.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoABContactsManager.h"
#import "MoContactSerializer.h"

@interface MoABContactsManager ()

@property (nonatomic) ABAddressBookRef addressBook;

@property (strong, nonatomic) MoContactSerializer *contactSerializer;

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
    self = [super init];
    if (self) {
        _addressBook =ABAddressBookCreateWithOptions(NULL, nil);
        _fieldsMask = MoContactFieldDefaults;
        [self observeAddressBook];
    }
    
    return self;
}

- (void)dealloc
{
    CFRelease(_addressBook);
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
    
    NSArray *contactsFromAB = (__bridge_transfer NSArray *)ABAddressBookCopyArrayOfAllPeople(_addressBook);
    
    NSMutableArray *contacts = [NSMutableArray array];
    
    for (id contactObj in contactsFromAB) {
        
        ABRecordRef contactRecord = (__bridge ABRecordRef)contactObj;
        
        MoContact *contact = [[MoContact alloc] init];
        
        ABRecordID contactId = ABRecordGetRecordID(contactRecord);
        
        [contact setContactId:contactId];
        
        if (_fieldsMask & MoContactFieldFirstName) {
            [contact setFirstName:[self objectFromProperty:kABPersonFirstNameProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldFirstNamePhonetic) {
            [contact setFirstNamePhonetic:[self objectFromProperty:kABPersonFirstNamePhoneticProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldLastName) {
            [contact setLastName:[self objectFromProperty:kABPersonLastNameProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldLastNamePhonetic) {
            [contact setLastNamePhonetic:[self objectFromProperty:kABPersonLastNamePhoneticProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldMiddleName) {
            [contact setMiddleName:[self objectFromProperty:kABPersonMiddleNameProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldMiddleNamePhonetic) {
            [contact setMiddleNamePhonetic:[self objectFromProperty:kABPersonMiddleNamePhoneticProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldPrefix) {
            [contact setPrefix:[self objectFromProperty:kABPersonPrefixProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldSuffixName) {
            [contact setSuffix:[self objectFromProperty:kABPersonSuffixProperty ofContact:contactRecord]];
        }
        
        [self setFullNameForContact:contact];
        
        if (_fieldsMask & MoContactFieldPhones) {
            [contact setPhones:[self arrayFromProperty:kABPersonPhoneProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldEmails) {
            [contact setEmails:[self arrayFromProperty:kABPersonEmailProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldNickName) {
            [contact setNickName:[self objectFromProperty:kABPersonNicknameProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldCompany) {
            [contact setCompany:[self objectFromProperty:kABPersonOrganizationProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldJobTitle) {
            [contact setJobTitle:[self objectFromProperty:kABPersonJobTitleProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldDepartment) {
            [contact setDepartment:[self objectFromProperty:kABPersonDepartmentProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldBirthday) {
            [contact setBirthday:[self objectFromProperty:kABPersonBirthdayProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldThumbnailProfilePicture) {
            NSData *thumImageData = (__bridge_transfer NSData*)ABPersonCopyImageDataWithFormat(contactRecord, kABPersonImageFormatThumbnail);
            if (thumImageData) {
                [contact setThumbnailProfilePicture:[UIImage imageWithData:thumImageData]];
            }
        }
        
        if (_fieldsMask & MoContactFieldOriginalProfilePicture) {
            NSData *originalImageData = (__bridge_transfer NSData*)ABPersonCopyImageDataWithFormat(contactRecord, kABPersonImageFormatOriginalSize);
            if (originalImageData) {
                [contact setOriginalProfilePicture:[UIImage imageWithData:originalImageData]];
            }
        }
        
        if (_fieldsMask & MoContactFieldNote) {
            [contact setNote:[self objectFromProperty:kABPersonNoteProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldCreatedAt) {
            [contact setCreatedAt:[self objectFromProperty:kABPersonCreationDateProperty ofContact:contactRecord]];
        }
        
        if (_fieldsMask & MoContactFieldUpdatedAt) {
            [contact setUpdatedAt:[self objectFromProperty:kABPersonModificationDateProperty ofContact:contactRecord]];
        }
        
        if (_delegate) {
            if ([_delegate moABContatsManager:self shouldIncludeContact:contact]) {
                [contacts addObject:contact];
            }
        }else {
            [contacts addObject:contact];
        }
        
    }
    
    if (contactsBlock) {
        contactsBlock(kABAuthorizationStatusAuthorized, contacts);
    }
    
}

- (void)addContact:(MoContact *)contact
{
    ABRecordRef person = [self abRecordRefFromContact:contact];
    
    ABAddressBookAddRecord(_addressBook, person, NULL);
    ABAddressBookSave(_addressBook, NULL);
    
    CFRelease(person);
}

- (void)updateContact:(MoContact *)contact
{
    
}

- (BOOL)deleteContactWithId:(NSInteger)contactId
{
    ABRecordID contactRecordId = (ABRecordID)contactId;
    ABRecordRef contactRef = ABAddressBookGetPersonWithRecordID(_addressBook, contactRecordId);
    return ABAddressBookRemoveRecord(_addressBook, contactRef, NULL);
}

#pragma mark - Utils

- (id)objectFromProperty:(ABPropertyID)property ofContact:(ABRecordRef)contact
{
    CFTypeRef valueRef = ABRecordCopyValue(contact, property);
    id value = valueRef ? (__bridge_transfer id)valueRef : nil;
    return value;
}

- (NSArray *)arrayFromProperty:(ABPropertyID)property ofContact:(ABRecordRef)contact
{
    ABMultiValueRef multiValueRef = ABRecordCopyValue(contact, property);
    
    NSMutableArray *result = [NSMutableArray array];
    for (CFIndex i = 0; i < ABMultiValueGetCount(multiValueRef); i++) {
        
        NSString *value = (__bridge_transfer NSString *)(ABMultiValueCopyValueAtIndex(multiValueRef, i));
        CFStringRef locLabel = ABMultiValueCopyLabelAtIndex(multiValueRef, i);
        NSString *label =(__bridge_transfer NSString*)ABAddressBookCopyLocalizedLabel(locLabel);
        
        CFBridgingRelease(locLabel);
        
        [result addObject:@{label: value}];
        
    }
    CFRelease(multiValueRef);
    return result;
    
}

- (ABRecordRef)abRecordRefFromContact:(MoContact *)contact
{
    ABRecordRef person = ABPersonCreate(); // create a person
    
    [self updateContactRecord:person withContact:contact];
    
    return person;
}

- (void)updateContactRecord:(ABRecordRef)contactRecord withContact:(MoContact *)contact
{
    ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contact.firstName), nil);
    ABRecordSetValue(contactRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(contact.firstNamePhonetic), nil);
    
    ABRecordSetValue(contactRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(contact.lastName), nil);
    ABRecordSetValue(contactRecord, kABPersonLastNamePhoneticProperty, (__bridge CFTypeRef)(contact.lastNamePhonetic), nil);
    
    ABRecordSetValue(contactRecord, kABPersonMiddleNameProperty, (__bridge CFTypeRef)(contact.middleName), nil);
    ABRecordSetValue(contactRecord, kABPersonMiddleNamePhoneticProperty, (__bridge CFTypeRef)(contact.middleNamePhonetic), nil);
    
    ABRecordSetValue(contactRecord, kABPersonPrefixProperty, (__bridge CFTypeRef)(contact.prefix), nil);
    
    ABRecordSetValue(contactRecord, kABPersonSuffixProperty, (__bridge CFTypeRef)(contact.suffix), nil);
    
    ABRecordSetValue(contactRecord, kABPersonNicknameProperty, (__bridge CFTypeRef)(contact.nickName), nil);
    
    ABRecordSetValue(contactRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(contact.company), nil);
    
    ABRecordSetValue(contactRecord, kABPersonJobTitleProperty, (__bridge CFTypeRef)(contact.jobTitle), nil);
    
    ABRecordSetValue(contactRecord, kABPersonDepartmentProperty, (__bridge CFTypeRef)(contact.department), nil);
    
    ABRecordSetValue(contactRecord, kABPersonBirthdayProperty, (__bridge CFTypeRef)(contact.birthday), nil);
    
    ABRecordSetValue(contactRecord, kABPersonNoteProperty, (__bridge CFTypeRef)(contact.note), nil);
    
    if (contact.phones && [contact.phones count] > 0) {
        
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        for (NSDictionary *phoneData in contact.phones) {
            
            [phoneData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(obj), (__bridge CFTypeRef)(key), NULL);
            }];
            
        }
        
    }
    
    if (contact.emails && [contact.emails count] > 0) {
        
        ABMutableMultiValueRef emailsMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        for (NSDictionary *emailData in contact.emails) {
            
            [emailData enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                ABMultiValueAddValueAndLabel(emailsMultiValue, (__bridge CFTypeRef)(obj), (__bridge CFTypeRef)(key), NULL);
            }];
            
        }
        
    }
    
    if (contact.thumbnailProfilePicture) {
        NSData *data = UIImagePNGRepresentation(contact.thumbnailProfilePicture);
        ABPersonSetImageData(contactRecord, (__bridge CFDataRef)data, NULL);
    }else if(contact.originalProfilePicture) {
        NSData *data = UIImagePNGRepresentation(contact.originalProfilePicture);
        ABPersonSetImageData(contactRecord, (__bridge CFDataRef)data, NULL);
    }
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

#pragma mark - Address Book Observer

- (void)observeAddressBook
{
    ABAddressBookRegisterExternalChangeCallback(_addressBook, addressBookExternalChange, (__bridge void *)(self));
}

#pragma mark - Address Book did change callback

void addressBookExternalChange(ABAddressBookRef __unused addressBookRef, CFDictionaryRef __unused info, void *context)
{
    MoABContactsManager *manager = (__bridge MoABContactsManager *)(context);
    if([manager.delegate respondsToSelector:@selector(addressBookDidChange)])
    {
        [manager.delegate addressBookDidChange];
    }
}


@end
