//
//  CMComment.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMUser.h"

@interface CMComment : NSObject

@property (strong, nonatomic) NSString *content;
@property (strong, nonatomic) CMUser *user;
@property (nonatomic) NSInteger comicId;
@property (strong, nonatomic) NSDate *commentTime;
@end
