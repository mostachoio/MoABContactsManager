# MoABContactsManager

[![Build Status](https://api.travis-ci.org/Alterplay/APAddressBook.svg)](https://travis-ci.org/Alterplay/APAddressBook)
[![Version](https://img.shields.io/cocoapods/v/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)
[![License](https://img.shields.io/cocoapods/l/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)
[![Platform](https://img.shields.io/cocoapods/p/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)


## Installation

MoABContactsManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

## Basic Usage

# Get all contacts
```
[[MoABContactsManager sharedManager] contacts:^(ABAuthorizationStatus authorizationStatus, NSArray *contacts, NSError *error) {

    if (error) {
        // An error has ocurred
    }else {
        if (authorizationStatus == kABAuthorizationStatusAuthorized) {
            // Do something with contacts
        }else {
            // User didn't give permissions
        }
    }

}];

```

# Create contact

```
[[MoABContactsManager sharedManager] addContact:contact completion:^(NSError *error) {

    // Do sometihng

}];
```

# Update contact

```
[[MoABContactsManager sharedManager] updateContact:contact completion:^(NSError *error) {
    // Do something
}];

```

# Delete contact

```
[[MoABContactsManager sharedManager] deleteContactWithId:contact.contactId completion:^(NSError *error) {
    // Do something
}];

```

## Advanced Usage

# Use sort descriptor

```
[[MoABContactsManager sharedManager] setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
```

# Filter contacts
```
// Set MoABContactsManager delegate
[[MoABContactsManager sharedManager] setDelegate:self];

// Implement delegate
- (BOOL)moABContatsManager:(MoABContactsManager *)contactsManager shouldIncludeContact:(MoContact *)contact
{
    // Only show contacts with phones
    return [contact.phones count] > 0;
}

return YES;
}

```
# Select contacts fields

```
[[MoABContactsManager sharedManager] setFieldsMask:MoContactFieldFirstName | MoContactFieldLastName | MoContactFieldEmails | MoContactFieldPhones | MoContactFieldThumbnailProfilePicture];
```

```ruby
pod "MoABContactsManager"
```

## Author

[Diego Pais](https://github.com/diegof29)

## License

MoABContactsManager is available under the MIT license. See the LICENSE file for more info.