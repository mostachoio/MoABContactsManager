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

@property (nonatomic) dispatch_queue_t contactsManagerQueue;

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
        
        _contactsManagerQueue = dispatch_queue_create([@"io.mostachoio.moabcontactsmanager" cStringUsingEncoding:NSUTF8StringEncoding], NULL);
        
        CFErrorRef *error = NULL;
        _addressBook =ABAddressBookCreateWithOptions(NULL, error);

        if (error) {
            NSString *errorReason = (__bridge_transfer NSString *)CFErrorCopyFailureReason(*error);
            NSLog(@"[MoABContactsManager] initialization error: %@", errorReason);
            return nil;
        }
        
        _fieldsMask = MoContactFieldDefaults;
        _sortDescriptors = @[];
        [self observeAddressBook];
    }
    
    return self;
}

- (void)dealloc
{
    dispatch_sync(_contactsManagerQueue, ^{
        if (_addressBook) {
            CFRelease(_addressBook);
        }
    });
    #if !OS_OBJECT_USE_OBJC
        dispatch_release(_contactsManagerQueue);
    #endif
}

#pragma mark - Publics


- (void)contacts:(void (^)(ABAuthorizationStatus, NSArray *, NSError *))contactsBlock
{
    if (!contactsBlock) return;
    
    ABAuthorizationStatus abAuthStatus = ABAddressBookGetAuthorizationStatus();
    
    switch (abAuthStatus) {
            
        case kABAuthorizationStatusDenied:
        case kABAuthorizationStatusRestricted:
            contactsBlock(abAuthStatus, nil, nil);
            break;
            
        case kABAuthorizationStatusNotDetermined:
        {       // Ask user for permissions
            
            ABAddressBookRequestAccessWithCompletion(_addressBook, ^(bool granted, CFErrorRef error) {
                if (!error) {
                    if (granted) {
                        [self loadContactsFromAddressBookWithCompletionBlock:^(NSArray *contacts) {
                            contactsBlock(kABAuthorizationStatusAuthorized, contacts, nil);
                        }];
                    }else {
                        contactsBlock(kABAuthorizationStatusDenied, nil, nil);
                    }
                }else {
                    contactsBlock(kABAuthorizationStatusNotDetermined, nil, (__bridge NSError *)error);
                }
            });
            
            break;
        }
        case kABAuthorizationStatusAuthorized:
        {
            [self loadContactsFromAddressBookWithCompletionBlock:^(NSArray *contacts) {
                contactsBlock(kABAuthorizationStatusAuthorized, contacts, nil);
            }];
            break;
        }
    }
}

- (void)addContact:(MoContact *)contact completion:(void(^)(NSError *error))completion
{
    dispatch_async(_contactsManagerQueue, ^{
        
        CFErrorRef *errorRef = NULL;
        
        ABRecordRef person = [self abRecordRefFromContact:contact error:errorRef];
        CFRetain(person);
        
        ABAddressBookAddRecord(_addressBook, person, errorRef);
        
        ABAddressBookSave(_addressBook, errorRef);
        
        CFRelease(person);
        
        NSError *error = errorRef ? (__bridge NSError *)*errorRef : nil;
        if (!error) {
            ABRecordID contactId = ABRecordGetRecordID(person);
            [contact setContactId:contactId];
        }
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(error);
            });
        }
    });
}

- (void)updateContact:(MoContact *)contact completion:(void(^)(NSError *error))completion
{
    dispatch_async(_contactsManagerQueue, ^{
        CFErrorRef *errorRef = NULL;
        ABRecordID contactRecordId = (ABRecordID)contact.contactId;
        ABRecordRef person = ABAddressBookGetPersonWithRecordID(_addressBook, contactRecordId);
        
        if (person) {
            
            [self updateContactRecord:person withContact:contact error:errorRef];
            ABAddressBookSave(_addressBook, errorRef);
            
            if (completion) {
                
                NSError *error = errorRef ? (__bridge NSError *)*errorRef : nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    completion(error);
                });
            }
            
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (completion) {
                    completion(nil);
                }
            });
        }
        
    });
}

- (void)deleteContactWithId:(NSInteger)contactId completion:(void(^)(NSError *error))completion
{
    dispatch_async(_contactsManagerQueue, ^{
        
        CFErrorRef *errorRef = NULL;
        ABRecordID contactRecordId = (ABRecordID)contactId;
        ABRecordRef contactRef = ABAddressBookGetPersonWithRecordID(_addressBook, contactRecordId);
        
        ABAddressBookRemoveRecord(_addressBook, contactRef, errorRef);
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error = errorRef ? (__bridge NSError *)*errorRef : nil;
                completion(error);
            });
        }
        
    });
}

#pragma mark - Internals -

- (void)loadContactsFromAddressBookWithCompletionBlock:(void(^)(NSArray *))contactsBlock
{
    if (!contactsBlock) return;
    
    dispatch_async(_contactsManagerQueue, ^{
        
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
            
            if (_fieldsMask & MoContactFieldAddress) {
                [contact setAddresses:[self arrayFromProperty:kABPersonAddressProperty ofContact:contactRecord]];
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
            
        if (_sortDescriptors && [contacts count] > 0) {
            [contacts sortUsingDescriptors:_sortDescriptors];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            contactsBlock(contacts);
        });
        
    });
    
}

#pragma mark - Utils

- (void)updateArrayProperty:(ABPropertyID)property withArray:(NSArray *)array ofContact:(ABRecordRef)contact error:(CFErrorRef *)errorRef
{
    ABMutableMultiValueRef multiValueRef = ABMultiValueCreateMutable(kABMultiStringPropertyType);
    
    if (array && [array count] > 0) {
        
        for (NSDictionary *data in array) {
            
            [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                ABMultiValueAddValueAndLabel(multiValueRef, (__bridge CFTypeRef)(obj), (__bridge CFTypeRef)(key), NULL);
            }];
            
        }
    }
    ABRecordSetValue(contact, property, multiValueRef, errorRef);
    CFRelease(multiValueRef);
    
}

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

- (ABRecordRef)abRecordRefFromContact:(MoContact *)contact error:(CFErrorRef *)errorRef
{
    ABRecordRef person = ABPersonCreate(); // create a person
    
    [self updateContactRecord:person withContact:contact error:errorRef];
    CFAutorelease(person);
    return person;
}

- (void)updateContactRecord:(ABRecordRef)contactRecord withContact:(MoContact *)contact error:(CFErrorRef *)errorRef
{
    if ((_fieldsMask & MoContactFieldFirstName) || contact.firstName) {
        ABRecordSetValue(contactRecord, kABPersonFirstNameProperty, (__bridge CFTypeRef)(contact.firstName), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldFirstNamePhonetic) || contact.firstNamePhonetic) {
        ABRecordSetValue(contactRecord, kABPersonFirstNamePhoneticProperty, (__bridge CFTypeRef)(contact.firstNamePhonetic), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldLastName) || contact.lastName) {
        ABRecordSetValue(contactRecord, kABPersonLastNameProperty, (__bridge CFTypeRef)(contact.lastName), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldLastNamePhonetic) || contact.lastNamePhonetic) {
        ABRecordSetValue(contactRecord, kABPersonLastNamePhoneticProperty, (__bridge CFTypeRef)(contact.lastNamePhonetic), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldMiddleName) || contact.middleName) {
        ABRecordSetValue(contactRecord, kABPersonMiddleNameProperty, (__bridge CFTypeRef)(contact.middleName), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldMiddleNamePhonetic) || contact.middleNamePhonetic) {
        ABRecordSetValue(contactRecord, kABPersonMiddleNamePhoneticProperty, (__bridge CFTypeRef)(contact.middleNamePhonetic), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldPrefix) || contact.prefix) {
        ABRecordSetValue(contactRecord, kABPersonPrefixProperty, (__bridge CFTypeRef)(contact.prefix), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldSuffixName) || contact.suffix) {
        ABRecordSetValue(contactRecord, kABPersonSuffixProperty, (__bridge CFTypeRef)(contact.suffix), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldNickName) || contact.nickName) {
        ABRecordSetValue(contactRecord, kABPersonNicknameProperty, (__bridge CFTypeRef)(contact.nickName), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldCompany) || contact.company) {
        ABRecordSetValue(contactRecord, kABPersonOrganizationProperty, (__bridge CFTypeRef)(contact.company), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldJobTitle) || contact.jobTitle) {
        ABRecordSetValue(contactRecord, kABPersonJobTitleProperty, (__bridge CFTypeRef)(contact.jobTitle), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldDepartment) || contact.department) {
        ABRecordSetValue(contactRecord, kABPersonDepartmentProperty, (__bridge CFTypeRef)(contact.department), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldBirthday) || contact.birthday) {
        ABRecordSetValue(contactRecord, kABPersonBirthdayProperty, (__bridge CFTypeRef)(contact.birthday), errorRef);
    }
    
    if ((_fieldsMask & MoContactFieldNote) || contact.note) {
        ABRecordSetValue(contactRecord, kABPersonNoteProperty, (__bridge CFTypeRef)(contact.note), errorRef);
    }

    if ((_fieldsMask & MoContactFieldPhones) || (contact.phones && [contact.phones count] > 0)) {
        [self updateArrayProperty:kABPersonPhoneProperty withArray:contact.phones ofContact:contactRecord error:errorRef];
    }

    if ((_fieldsMask & MoContactFieldEmails) || (contact.emails && [contact.emails count] > 0)) {
        [self updateArrayProperty:kABPersonEmailProperty withArray:contact.emails ofContact:contactRecord error:errorRef];
    }
    
    if ((_fieldsMask & MoContactFieldAddress) || (contact.addresses && [contact.addresses count] > 0)) {
        [self updateArrayProperty:kABPersonAddressProperty withArray:contact.addresses ofContact:contactRecord error:errorRef];
    }
    
    if ((_fieldsMask & MoContactFieldThumbnailProfilePicture) && contact.thumbnailProfilePicture) {
        NSData *data = UIImagePNGRepresentation(contact.thumbnailProfilePicture);
        ABPersonSetImageData(contactRecord, (__bridge CFDataRef)data, errorRef);
    }else if((_fieldsMask & MoContactFieldOriginalProfilePicture) && contact.originalProfilePicture) {
        NSData *data = UIImagePNGRepresentation(contact.originalProfilePicture);
        ABPersonSetImageData(contactRecord, (__bridge CFDataRef)data, errorRef);
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
