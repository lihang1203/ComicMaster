//
//  CMStartScreenViewController.m
//  ComicMaster
//
//  Created by Hang Li on 8/22/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMStartScreenViewController.h"

@interface CMStartScreenViewController ()

@end

@implementation CMStartScreenViewController

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
	[NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(showMsg:) userInfo:nil repeats:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showMsg:(NSTimer *)timer
{
    [UIView animateWithDuration:2.0 animations:^{
        self.titleLabel.alpha = 1.0;
    }completion:^(BOOL finished){
        [UIView animateWithDuration:2.0 animations:^{
            self.titleLabel.alpha = 0;
        }completion:^(BOOL finished) {
            [self performSegueWithIdentifier:@"gotoHome" sender:self];
        }];
    }];
}

@end
