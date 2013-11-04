//
//  CMComicDAO.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMGenericDAO.h"
#import "CMComic.h"

@interface CMComicDAO : CMGenericDAO

+ (CMComicDAO *)getInstance;

- (NSMutableArray *)listAllByUser:(NSString *)userName;
- (BOOL)addComic:(CMComic *)comic;
- (BOOL)updateComic:(CMComic *)comic;
- (BOOL)deleteComicById:(NSInteger)comicId;
@end
