//
//  CMCommentViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/18/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASIHTTPRequestDelegate.h"

@interface CMCommentViewController : UIViewController<UITableViewDataSource, UITableViewDelegate, ASIHTTPRequestDelegate, UIAlertViewDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (weak, nonatomic) IBOutlet UITableView *commentTableView;
@property (nonatomic)NSInteger curComicId;

- (IBAction)cancel:(id)sender;
- (IBAction)addComment:(id)sender;
@end
