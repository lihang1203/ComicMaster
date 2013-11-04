//
//  CMCommentCell.h
//  ComicMaster
//
//  Created by Hang Li on 8/18/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCommentCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *commentCellView;
@property (weak, nonatomic) IBOutlet UIImageView *authorImageView;
@property (weak, nonatomic) IBOutlet UILabel *authorNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *commentTimeLabel;

@end
