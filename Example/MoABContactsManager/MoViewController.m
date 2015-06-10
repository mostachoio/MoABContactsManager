//
//  ViewController.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoViewController.h"
#import <Mo>

@interface ViewController () <MoABContactsManagerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MoABContactsManager sharedManager] setDelegate:self];
    [[MoABContactsManager sharedManager] contacts:^(ABAuthorizationStatus authorizationStatus, NSArray *contacts) {
        
        if (authorizationStatus == kABAuthorizationStatusAuthorized) {
            
            NSLog(@"First Contact = %@", [contacts[0] asDictionary]);
            NSLog(@"Contacts count = %i", (int)[contacts count]);
        
        }else {
            NSLog(@"No permissions!");
        }
        
    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - MoABContactsManagerDelegate

- (BOOL)moABContatsManager:(MoABContactsManager *)contactsManager shouldIncludeContact:(MoContact *)contact
{
    return ([contact.phones count] > 0) || ([contact.emails count] > 0);
}

@end
