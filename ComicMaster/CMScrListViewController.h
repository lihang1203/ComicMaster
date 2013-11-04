//
//  CMScrListViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/8/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"
#import "CMCommentButton.h"

@interface CMScrListViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ASIHTTPRequestDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *comicListCollectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *actIndicator;

- (IBAction)reload:(id)sender;

- (IBAction)commentClicked:(CMCommentButton *)sender;
@end
