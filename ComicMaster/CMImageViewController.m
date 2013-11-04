//
//  CMImageViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/9/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMImageViewController.h"
#import "CMComicDAO.h"
#import "ASIFormDataRequest.h"
#import "Base64.h"
#import "CMAppDelegate.h"

@interface CMImageViewController ()

@end

@implementation CMImageViewController

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
    
    self.imgView.contentMode = UIViewContentModeCenter;
	self.imgView.image = self.comic.image;
    self.titleLabel.text = self.comic.title;
    self.imgView.frame = CGRectMake(0, 0, 320, 504);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)upload:(id)sender
{
    NSData *imgData = UIImagePNGRepresentation(self.comic.image);
    [Base64 initialize];
    NSString *strEncoded = [Base64 encode:imgData];
    // send request
    NSURL *url = [NSURL URLWithString:@"http://localhost/~hang/comicMaster/insertComic.php"];
    ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
    request.delegate = self;
    [request setRequestMethod:@"POST"];
    [request addPostValue:self.comic.title forKey:@"title"];
    [request addPostValue:((CMAppDelegate *)[[UIApplication sharedApplication] delegate]).loginUser.userName forKey:@"author"];
    NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
    gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *dateString = [gmtDateFormatter stringFromDate:[NSDate date]];
    [request addPostValue:dateString forKey:@"uploadTime"];
    [request addPostValue:strEncoded forKey:@"image"];
    [request startAsynchronous];
}

- (void) requestFinished:(ASIHTTPRequest *)request
{
    [self showAlert:[request responseString]];
}

- (void) requestFailed:(ASIHTTPRequest *)request
{
    // do sth
}

-(void) showAlert:(NSString *)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)workon:(id)sender
{
    [self dismissViewControllerAnimated:NO completion:^{
        [self.prevVC performSegueWithIdentifier:@"gotoCanvas" sender:self.comic];
    }];
}

- (IBAction)deleteWork:(id)sender
{
    [[CMComicDAO getInstance] deleteComicById:self.comic.comicId];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
