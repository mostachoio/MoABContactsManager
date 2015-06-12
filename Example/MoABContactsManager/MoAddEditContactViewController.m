//
//  MoAddEditContactViewController.m
//  MoABContactsManager
//
//  Created by Diego Pais on 6/11/15.
//  Copyright (c) 2015 Diego Pais. All rights reserved.
//

#import "MoAddEditContactViewController.h"
#import <MoABContactsManager/MoABContactsManager.h>

@interface MoAddEditContactViewController ()

@property (weak, nonatomic) IBOutlet UITextField *firstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *phoneTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation MoAddEditContactViewController

- (void)viewDidLoad {

    [super viewDidLoad];

    if (_contact) {
        
        [_firstNameTextField setText:_contact.firstName];
        [_lastNameTextField setText:_contact.lastName];
        
        if (_contact.phones && [_contact.phones count] > 0) {
            NSArray *phonesValues = [_contact.phones[0] allValues];
            [_phoneTextField setText:[NSString stringWithFormat:@"%@", phonesValues[0]]];
        }
        
        if (_contact.emails && [_contact.emails count] > 0) {
            NSArray *emailsValues = [_contact.emails[0] allValues];
            [_emailTextField setText:[NSString stringWithFormat:@"%@", emailsValues[0]]];
        }
        
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Actions

- (IBAction)saveButtonTouched:(UIBarButtonItem *)sender
{
    if (_contact) {
        [self doUpdate];
    }else {
        [self doSave];
    }
    
}

#pragma mark - Internals

- (void)doSave
{
    
    MoContact *newContact = [[MoContact alloc] init];
    
    [newContact setFirstName:_firstNameTextField.text];
    [newContact setLastName:_lastNameTextField.text];
    [newContact setPhones:@[@{@"work": _phoneTextField.text}]];
    [newContact setEmails:@[@{@"work": _emailTextField.text}]];
    
    [[MoABContactsManager sharedManager] addContact:newContact];
    
}

- (void)doUpdate
{
    [_contact setFirstName:_firstNameTextField.text];
    [_contact setLastName:_lastNameTextField.text];
    
    [_contact setPhones:@[@{@"work": _phoneTextField.text}]];
    [_contact setEmails:@[@{@"work": _emailTextField.text}]];
    
    [[MoABContactsManager sharedManager] updateContact:_contact];
}

@end
