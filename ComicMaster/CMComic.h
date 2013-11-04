//
//  CMComic.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMUser.h"

@interface CMComic : NSObject

@property (nonatomic) NSInteger comicId;
@property (strong, nonatomic) UIImage *image;
@property (strong, nonatomic) CMUser *author;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSDate *updateTime;
@end
