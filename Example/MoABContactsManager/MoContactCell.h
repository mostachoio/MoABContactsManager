//
//  MoContactCell.h
//  MoABContactsManager
//
//  Created by Diego Pais on 6/10/15.
//  Copyright (c) 2015 Diego Pais. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoContactCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePictureImageView;
@property (weak, nonatomic) IBOutlet UILabel *fullNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailsLabel;

@end
