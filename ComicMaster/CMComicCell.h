//
//  CMComicCell.h
//  ComicMaster
//
//  Created by Hang Li on 8/12/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMComicCellView.h"
#import "CMCommentButton.h"

@interface CMComicCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet CMComicCellView *comicCellView;
@property (weak, nonatomic) IBOutlet UIView *comicContentView;
@property (weak, nonatomic) IBOutlet UIView *comicBottomBarView;
@property (weak, nonatomic) IBOutlet UIImageView *comicCellImgView;
@property (weak, nonatomic) IBOutlet UILabel *comicAuthorLabel;
@property (weak, nonatomic) IBOutlet UILabel *comicTitleLabel;
@property (weak, nonatomic) IBOutlet CMCommentButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *comicUploadTimeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *comicAuthorAvatarImgView;

@end
