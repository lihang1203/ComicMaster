//
//  CMLoginViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/12/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMLoginViewController.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Base64.h"
#import "CMUser.h"
#import "CMAppDelegate.h"
#import "KeychainItemWrapper.h"
#import "CMRegisterViewController.h"

@interface CMLoginViewController ()

@end

@implementation CMLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (IBAction)dismissKB:(id)sender
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
}

- (IBAction)login:(id)sender
{
    if (_userNameTF.text.length == 0 || _passwordTF.text.length == 0) {
        [self showAlert:@"Please enter username and password to login"];
        return;
    }
    NSString *urlStr = [NSString stringWithFormat:@"http://localhost/~hang/comicMaster/findUser.php?userName=%@", _userNameTF.text];
    NSURL *url = [NSURL URLWithString:urlStr];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
}

- (IBAction)back:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    NSString *resStr = request.responseString;
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    NSArray *jsonObject = [parser objectWithString:resStr error:nil];
    if (jsonObject.count == 0) {
        [self showAlert:@"user does not exist"];
        return;
    }
    NSDictionary *firstItem = [jsonObject objectAtIndex:0];
    NSString *resPassword = [firstItem objectForKey:@"password"];
    if (![resPassword isEqualToString:_passwordTF.text]) {
        [self showAlert:@"password is not correct"];
        return;
    }
    CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
    if (curUser == nil) {
        curUser = [[CMUser alloc] init];
    }
    curUser.userName = [firstItem objectForKey:@"username"];
    curUser.password = resPassword;
    NSString *imgStr = [firstItem objectForKey:@"avatar"];
    NSData *imgData = [Base64 decode:imgStr];
    UIImage *selImage = [UIImage imageWithData:imgData];
    curUser.avatar = selImage;
    ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser = curUser;
    
    // store u/p in keychain
    if (self.rememberSwitch.isOn) {
        KeychainItemWrapper *kcItem = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).keyChainItem;
        [kcItem setObject:curUser.userName forKey:(__bridge id)(kSecAttrAccount)];
        [kcItem setObject:curUser.password forKey:(__bridge id)(kSecValueData)];
    } else {
        [((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).keyChainItem resetKeychainItem];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // do sth
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"gotoRegister"]) {
        ((CMRegisterViewController *)segue.destinationViewController).isNew = YES;
    }
}
@end
