//
//  CMUserSettingViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/20/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMUserSettingViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *userInfoBtn;

- (IBAction)changeLoginStatus:(id)sender;
- (IBAction)gotoUserInfo:(id)sender;

@end
