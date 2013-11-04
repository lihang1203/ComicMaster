//
//  CMRegisterViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/12/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMInputViewController.h"
#import "ASIHTTPRequestDelegate.h"

@interface CMRegisterViewController : CMInputViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, ASIHTTPRequestDelegate>

@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *rePasswordTF;
@property (weak, nonatomic) IBOutlet UIImageView *avatarImgView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (nonatomic) BOOL isNew;

- (IBAction)regUser:(id)sender;
- (IBAction)cancel:(id)sender;
- (IBAction)changeAvatar:(id)sender;
- (IBAction)dismissKB:(id)sender;
@end
