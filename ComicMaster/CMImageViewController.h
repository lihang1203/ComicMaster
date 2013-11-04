//
//  CMImageViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/9/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMComic.h"
#import "CMCollectionViewController.h"
#import "ASIHTTPRequestDelegate.h"

@interface CMImageViewController : UIViewController<ASIHTTPRequestDelegate>

@property (weak, nonatomic) CMCollectionViewController *prevVC;
@property (nonatomic) CMComic *comic; // so that this can be set when doing the segue
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imgView;
- (IBAction)cancel:(id)sender;
- (IBAction)upload:(id)sender;
- (IBAction)workon:(id)sender;
- (IBAction)deleteWork:(id)sender;

@end
