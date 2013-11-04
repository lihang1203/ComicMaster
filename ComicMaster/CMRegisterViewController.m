//
//  CMRegisterViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/12/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CMRegisterViewController.h"
#import "CMUser.h"
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "SBJson.h"
#import "Base64.h"
#import "CMAppDelegate.h"

@interface CMRegisterViewController ()
{
    CMUser *_regUser;
}
@end

@implementation CMRegisterViewController

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
	_regUser = [[CMUser alloc] init];
    _regUser.avatar = _avatarImgView.image;
    _avatarImgView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    _avatarImgView.layer.borderWidth = 4;
    _avatarImgView.layer.cornerRadius = 12;
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isNew) {
        self.titleLabel.text = @"Register";
    } else {
        self.titleLabel.text = @"Update";
        self.userNameTF.enabled = false;
        CMUser *curUser = ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser;
        self.userNameTF.text = curUser.userName;
        self.passwordTF.text = curUser.password;
        self.rePasswordTF.text = curUser.password;
        self.avatarImgView.image = curUser.avatar;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)regUser:(id)sender
{
    if (![self validateAll]) {
        return;
    }
    
    NSURL *url = nil;
    ASIFormDataRequest *request = nil;
    // check username existense
    if (self.isNew) {
        NSString *urlStr = [NSString stringWithFormat:@"http://localhost/~hang/comicMaster/findUser.php?userName=%@", _userNameTF.text];
        url = [NSURL URLWithString:urlStr];
        request = [ASIFormDataRequest requestWithURL:url];
        request.delegate = self;
        [request setRequestMethod:@"GET"];
        [request startSynchronous];
        NSString *resStr = request.responseString;
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        NSArray *jsonObject = [parser objectWithString:resStr error:nil];
        if (jsonObject.count > 0) {
            [self showAlert:@"username is taken, try another one"];
            return;
        }
    }
    
    _regUser.userName = _userNameTF.text;
    _regUser.password = _passwordTF.text;
    if (self.isNew) {
        url = [NSURL URLWithString:@"http://localhost/~hang/comicMaster/insertUser.php"];
    } else {
        url = [NSURL URLWithString:@"http://localhost/~hang/comicMaster/updateUser.php"];
    }
    
    request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addPostValue:_regUser.userName forKey:@"userName"];
    [request addPostValue:_regUser.password forKey:@"password"];
    NSData *imgData = UIImagePNGRepresentation(_regUser.avatar);
    [Base64 initialize];
    NSString *strEncoded = [Base64 encode:imgData];
    [request addPostValue:strEncoded forKey:@"avatar"];
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    if ([request.responseString isEqualToString:@"user created"]) {
        [self showAlert:@"Registration succeeded, Thank you"];
        [self dismissViewControllerAnimated:YES completion:nil];
    } else if ([request.responseString isEqualToString:@"user updated"]) {
        [self showAlert:@"Update succeeded, Thank you"];
        [self dismissViewControllerAnimated:YES completion:nil];
        ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser = _regUser;
    }
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // do sth
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)changeAvatar:(id)sender
{
    UIImagePickerController *imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.delegate = self;
    imgPicker.allowsEditing = true;
    imgPicker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imgPicker animated:YES completion:nil];
}

- (IBAction)dismissKB:(id)sender
{
    [_userNameTF resignFirstResponder];
    [_passwordTF resignFirstResponder];
    [_rePasswordTF resignFirstResponder];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    _regUser.avatar = [info objectForKey:UIImagePickerControllerEditedImage];
    if (!_regUser.avatar) { // picture could be edited or not
        _regUser.avatar = [info objectForKey:UIImagePickerControllerOriginalImage];
    }
    _avatarImgView.image = _regUser.avatar;
    ((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser.avatar = _avatarImgView.image;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)aTextField
{
    return [self validateInput:aTextField];
}

- (BOOL)validateInput:(UITextField *)aTextField
{
    if (aTextField == _userNameTF) {
        if (aTextField.text.length == 0) {
            [self showAlert:@"username cannot be empty"];
            return NO;
        }
    } else if (aTextField == _passwordTF) {
        if (aTextField.text.length < 8) {
            [self showAlert:@"please input a password with at least 8 characters"];
            return NO;
        }
    } else if (aTextField == _rePasswordTF) {
        if (![aTextField.text isEqualToString:_passwordTF.text]) {
            [self showAlert:@"password not identical with previous input"];
            return NO;
        }
    }
    return YES;
}

- (BOOL) validateAll
{
    return [self validateInput:_userNameTF]
        && [self validateInput:_passwordTF]
    && [self validateInput:_rePasswordTF];
}
@end
