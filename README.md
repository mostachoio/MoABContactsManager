# MoABContactsManager

[![Build Status](https://api.travis-ci.org/Alterplay/APAddressBook.svg)](https://travis-ci.org/Alterplay/APAddressBook)
[![Version](https://img.shields.io/cocoapods/v/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)
[![License](https://img.shields.io/cocoapods/l/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)
[![Platform](https://img.shields.io/cocoapods/p/MoABContactsManager.svg?style=flat)](http://cocoapods.org/pods/MoABContactsManager)


## Installation

MoABContactsManager is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MoABContactsManager"
```

## Basic Usage

### Get all contacts

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

### Create contact

```
[[MoABContactsManager sharedManager] addContact:contact completion:^(NSError *error) {
    // Do sometihng
}];
```

### Update contact

```
[[MoABContactsManager sharedManager] updateContact:contact completion:^(NSError *error) {
    // Do something
}];

```

### Delete contact

```
[[MoABContactsManager sharedManager] deleteContactWithId:contact.contactId completion:^(NSError *error) {
    // Do something
}];

```

## Advanced Usage

### Use sort descriptor

```
[[MoABContactsManager sharedManager] setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
```

### Filter contacts

```
// Set MoABContactsManager delegate
[[MoABContactsManager sharedManager] setDelegate:self];

// Implement delegate
- (BOOL)moABContatsManager:(MoABContactsManager *)contactsManager shouldIncludeContact:(MoContact *)contact
{
    // Only show contacts with phones
    return [contact.phones count] > 0;
}
```

### Select contacts fields to fetch

```
[[MoABContactsManager sharedManager] setFieldsMask:MoContactFieldFirstName | MoContactFieldLastName | MoContactFieldEmails | MoContactFieldPhones | MoContactFieldThumbnailProfilePicture];
```

### Serialize Contacts

```
NSLog(@"Serialized Contact: %@", [contact asDictionary]);
```

Output:

```
{
    "contact_id" = 888;
    "emails" =
            (
                {
                    "work" = "johndoe@work.com"
                },
                {
                    "home" = "johndoe@home.com"
                }
            );
    "emails_values" =     
                    (
                        "johndoe@mail.com",
                        "johndoe@home.com"
                    );
    "first_name" = John;
    "last_name" = Doe;
    "full_name" = "John Doe";
    "phones" =    
            (
                {
                    "mobile" = "+13121123345"    
                }
            );
    "phones_values" =     
                    (
                        "+13121123345"
                    )
    "addresses" =     
                (
                    {
                        "work" = 
                                {
                                    "City" = "Cupertino",
                                    "Country" = "United States",
                                    "CountryCode" = "us",
                                    "State" = "CA",
                                    "Street" = "1 Infinite Loop",
                                    "ZIP" = "95014"
                                }
                    }
                )
}
```

## What's next?

* Handle linked contacts

## Author

[Diego Pais](https://github.com/diegof29)

## License

MoABContactsManager is available under the MIT license. See the LICENSE file for more info.