//
//  CMComicLibViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCanvasViewController.h"

@interface CMComicLibViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic)CMCanvasViewController *parentVC;
- (IBAction)back:(id)sender;
@end
