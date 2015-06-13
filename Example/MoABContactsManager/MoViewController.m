//
//  ViewController.m
//  MoABContactsManagerDemo
//
//  Created by Diego Pais on 6/6/15.
//  Copyright (c) 2015 mostachoio. All rights reserved.
//

#import "MoViewController.h"
#import <MoABContactsManager/MoABContactsManager.h>
#import "MoContactCell.h"
#import "MoAddEditContactViewController.h"

@interface MoViewController () <MoABContactsManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *contacts;

@property (weak, nonatomic) IBOutlet UITableView *contactsTableView;

@property (nonatomic) BOOL onlyWithPhones;
@property (nonatomic) BOOL onlyWithEmails;

@property (strong, nonatomic) MoContact *selectedContact;

@end

@implementation MoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MoABContactsManager sharedManager] setSortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"fullName" ascending:YES]]];
    [[MoABContactsManager sharedManager] setFieldsMask:MoContactFieldFirstName | MoContactFieldLastName | MoContactFieldEmails | MoContactFieldPhones | MoContactFieldThumbnailProfilePicture];
    [[MoABContactsManager sharedManager] setDelegate:self];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self loadContacts];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"toAddEditContact"]) {
        MoAddEditContactViewController *addEditContactVC  = segue.destinationViewController;
        [addEditContactVC setContact:_selectedContact];
    }
}

#pragma mark - Load Contacs

- (void)loadContacts
{
    [[MoABContactsManager sharedManager] contacts:^(ABAuthorizationStatus authorizationStatus, NSArray *contacts, NSError *error) {
        
        if (error) {
            NSLog(@"Error = %@", [error localizedDescription]);
        }else {
            if (authorizationStatus == kABAuthorizationStatusAuthorized) {
                _contacts = contacts;
                [_contactsTableView reloadData];
            }else {
                NSLog(@"No permissions!");
            }
        }
        
    }];
}

#pragma mark - MoABContactsManagerDelegate

- (BOOL)moABContatsManager:(MoABContactsManager *)contactsManager shouldIncludeContact:(MoContact *)contact
{
    if (_onlyWithPhones) {
        return [contact.phones count] > 0;
    }
    
    if (_onlyWithEmails) {
        return [contact.emails count] > 0;
    }
    
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_contacts count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 90.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"MoContactCell";
    
    MoContactCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    MoContact *contact = _contacts[indexPath.row];
    
    [cell.profilePictureImageView setImage:contact.thumbnailProfilePicture];
    [cell.fullNameLabel setText:contact.fullName];
    
    if (contact.phones && [contact.phones count] > 0) {
        NSArray *phonesValues = [contact.phones[0] allValues];
        [cell.phoneLabel setText:[NSString stringWithFormat:@"%@", phonesValues[0]]];
    }else {
        [cell.phoneLabel setText:@""];
    }
    
    if (contact.emails && [contact.emails count] > 0) {
        NSArray *emailsValues = [contact.emails[0] allValues];
        [cell.emailsLabel setText:[NSString stringWithFormat:@"%@", emailsValues[0]]];
    }else {
        [cell.emailsLabel setText:@""];
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    _selectedContact = _contacts[indexPath.row];
    [self performSegueWithIdentifier:@"toAddEditContact" sender:self];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        MoContact *contact = _contacts[indexPath.row];
        [[MoABContactsManager sharedManager] deleteContactWithId:contact.contactId completion:^(NSError *error) {
            if (!error) {
                NSMutableArray *mutContacts = [NSMutableArray arrayWithArray:_contacts];
                [mutContacts removeObject:contact];
                _contacts = mutContacts;
                [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            }
        }];
        
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

#pragma mark - Actions

- (IBAction)filtersControlValueChanged:(UISegmentedControl *)sender
{
    switch (sender.selectedSegmentIndex) {
        case 0:
            _onlyWithEmails = NO;
            _onlyWithPhones = NO;
            break;
        case 1:
            _onlyWithPhones = YES;
            _onlyWithEmails = NO;
            break;
            
        case 2:
            _onlyWithPhones = NO;
            _onlyWithEmails = YES;
            break;
    }
    
    [self loadContacts];
}

- (IBAction)addContactButtonTouched:(UIBarButtonItem *)sender
{
    _selectedContact = nil;
    [self performSegueWithIdentifier:@"toAddEditContact" sender:self];
}


@end
