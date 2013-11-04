//
//  CMCollectionViewController.h
//  ComicMaster
//
//  Created by Hang Li on 8/9/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCollectionViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

- (IBAction)newComicSelected:(id)sender;
@property (weak, nonatomic) IBOutlet UICollectionView *imgCollectionView;
@end
