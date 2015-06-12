//
//  MoAddEditContactViewController.h
//  MoABContactsManager
//
//  Created by Diego Pais on 6/11/15.
//  Copyright (c) 2015 Diego Pais. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MoABContactsManager/MoContact.h>

@interface MoAddEditContactViewController : UIViewController

@property (nonatomic, strong) MoContact *contact;
@property (nonatomic) BOOL editingMode;

@end
