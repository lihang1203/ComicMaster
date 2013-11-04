//
//  CMLoginViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/12/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMInputViewController.h"
#import "ASIHTTPRequestDelegate.h"

@interface CMLoginViewController : CMInputViewController<ASIHTTPRequestDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (strong, nonatomic) id targetVC; // where to go after logging in

- (IBAction)dismissKB:(id)sender;
- (IBAction)login:(id)sender;
- (IBAction)back:(id)sender;
@property (weak, nonatomic) IBOutlet UISwitch *rememberSwitch;
@end
