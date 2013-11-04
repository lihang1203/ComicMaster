//
//  CMUserSettingViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/20/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMUserSettingViewController.h"
#import "CMAppDelegate.h"
#import "CMUser.h"
#import "KeychainItemWrapper.h"
#import "CMRegisterViewController.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Base64.h"

@interface CMUserSettingViewController ()

@end

@implementation CMUserSettingViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
    CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    if (curUser) {
        [self.loginBtn setTitle:@"logout" forState:UIControlStateNormal];
        self.userNameLabel.text = curUser.userName;
        self.userInfoBtn.enabled = YES;
    } else {
        [self.loginBtn setTitle:@"login" forState:UIControlStateNormal];
        self.userNameLabel.text = @"guest";
        self.userInfoBtn.enabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)changeLoginStatus:(id)sender
{
    CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    if (curUser) {
        ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser = nil;
        KeychainItemWrapper *kcItem = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).keyChainItem;
        [kcItem resetKeychainItem];
        [self.loginBtn setTitle:@"login" forState:UIControlStateNormal];
        self.userNameLabel.text = @"guest";
        self.userInfoBtn.enabled = NO;
    } else {
        [self performSegueWithIdentifier:@"setting2login" sender:self];
    }
}

- (IBAction)gotoUserInfo:(id)sender
{
    CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/~hang/comicMaster/findUser.php?userName=%@", curUser.userName];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"GET"];
    [request startSynchronous];
    NSString *resStr = request.responseString;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *jsonObject = [parser objectWithString:resStr error:nil];
    if (jsonObject.count > 0) {
        NSDictionary *firstItem = [jsonObject objectAtIndex:0];
        NSString *imgStr = [firstItem objectForKey:@"avatar"];
        NSData *imgData = [Base64 decode:imgStr];
        UIImage *selImage = [UIImage imageWithData:imgData];
        curUser.avatar = selImage;
    }
    [self performSegueWithIdentifier:@"settingToUserInfo" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"settingToUserInfo"]) {
        ((CMRegisterViewController *)segue.destinationViewController).isNew = NO;
    }
}
@end
