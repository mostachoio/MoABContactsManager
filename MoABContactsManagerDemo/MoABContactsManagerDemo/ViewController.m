//
//  ViewController.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "ViewController.h"
#import "MoABContactsManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [[MoABContactsManager sharedManager] contacts:^(ABAuthorizationStatus authorizationStatus, NSArray *contacts) {
        
        if (authorizationStatus == kABAuthorizationStatusAuthorized) {
            NSLog(@"Contacts = %@", contacts);
        }else {
            NSLog(@"No permissions!");
        }
        
    }];


}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
