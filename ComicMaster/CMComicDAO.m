//
//  CMComicDAO.m
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMComicDAO.h"

@implementation CMComicDAO

+ (CMComicDAO *)getInstance
{
    static CMComicDAO *theIns = nil;
    if (theIns == nil) {
        @synchronized(self) {
            if (theIns == nil) {
                theIns = [[self alloc] init];
            }
        }
    }
    return theIns;
}

- (NSMutableArray *)listAllByUser:(NSString *)userName
{
    NSMutableArray *comics = [[NSMutableArray alloc] init];
    @try {
        if ([self openDB:LOCAL_DB_NAME]) {
            NSString *sqlNSS = [NSString stringWithFormat:@"SELECT * FROM comic_t WHERE author = '%@'", userName];
            const char *sql = [sqlNSS UTF8String];
            sqlite3_stmt *sqlStmt;
            if(sqlite3_prepare_v2(dbIns, sql, -1, &sqlStmt, NULL) != SQLITE_OK)
            {
                NSLog(@"Problem with prepare comic listing statement");
                return comics;
            }
            while (sqlite3_step(sqlStmt) == SQLITE_ROW) {
                CMComic *comic = [[CMComic alloc] init];
                comic.author = [[CMUser alloc] init];
                comic.comicId = sqlite3_column_int(sqlStmt, 0);
                comic.title = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStmt, 1)];
                comic.author.userName = [NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStmt, 2)];
                NSDateFormatter *gmtDateFormatter = [[NSDateFormatter alloc] init];
                gmtDateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
                comic.updateTime = [gmtDateFormatter dateFromString:[NSString stringWithUTF8String:(char *)sqlite3_column_text(sqlStmt, 3)]];
                const char *rawImgData = sqlite3_column_blob(sqlStmt, 4);
                int rawDataLen = sqlite3_column_bytes(sqlStmt, 4);
                NSData *imgData = [NSData dataWithBytes:rawImgData length:rawDataLen];
                comic.image = [[UIImage alloc] initWithData:imgData];
                [comics addObject:comic];
            }
            sqlite3_finalize(sqlStmt);
            return comics;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Listing comics failed because: %@", [exception reason]);
    }
    @finally {
        sqlite3_close(dbIns);
        return comics;
    }
}

- (BOOL)addComic:(CMComic *)comic
{
    @try {
        if ([self openDB:LOCAL_DB_NAME]) {
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO comic_t (author, title, updatetime, image) VALUES ('%@', '%@', '%@', ?)", comic.author.userName, comic.title, comic.updateTime];
            const char *sqlStr = [sql UTF8String];
            sqlite3_stmt *sqlStmt;
            if (sqlite3_prepare_v2(dbIns, sqlStr,  -1, &sqlStmt, NULL) != SQLITE_OK) {
                NSLog(@"Problem with prepare comic insert statement");
                return NO;
            }
            NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(comic.image)];
            if (sqlite3_bind_blob(sqlStmt, 1, [imgData bytes], [imgData length], SQLITE_TRANSIENT) != SQLITE_OK) {
                NSLog(@"Problem with prepare binding image blob");
                return NO;
            }
            if (sqlite3_step(sqlStmt) == SQLITE_DONE) {
                NSLog(@"comic saved locally.");
            } else {
                NSLog(@"failed to save comic in local DB.");
            }
            sqlite3_finalize(sqlStmt);
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot save comic in local DB because %@", [exception reason]);
    }
    @finally {
        sqlite3_close(dbIns);
    }
}

- (BOOL)updateComic:(CMComic *)comic
{
    @try {
        if ([self openDB:LOCAL_DB_NAME]) {
            NSString *sql = [NSString stringWithFormat:@"UPDATE comic_t SET author = '%@', title = '%@', updatetime = '%@', image = ? WHERE id = '%i'", comic.author.userName, comic.title, comic.updateTime, comic.comicId];
            const char *sqlStr = [sql UTF8String];
            sqlite3_stmt *sqlStmt;
            if (sqlite3_prepare_v2(dbIns, sqlStr,  -1, &sqlStmt, NULL) != SQLITE_OK) {
                NSLog(@"Problem with prepare comic update statement");
                return NO;
            }
            NSData *imgData = [NSData dataWithData:UIImagePNGRepresentation(comic.image)];
            if (sqlite3_bind_blob(sqlStmt, 1, [imgData bytes], [imgData length], SQLITE_TRANSIENT) != SQLITE_OK) {
                NSLog(@"Problem with prepare binding image blob");
                return NO;
            }
            if (sqlite3_step(sqlStmt) == SQLITE_DONE) {
                NSLog(@"comic updated locally.");
            } else {
                NSLog(@"failed to update comic in local DB.");
            }
            sqlite3_finalize(sqlStmt);
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot update comic in local DB because %@", [exception reason]);
    }
    @finally {
        sqlite3_close(dbIns);
    }
}

- (BOOL)deleteComicById:(NSInteger)comicId
{
    @try {
        if ([self openDB:LOCAL_DB_NAME]) {
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM comic_t WHERE id = '%i'", comicId];
            const char *sqlStr = [sql UTF8String];
            sqlite3_stmt *sqlStmt;
            if (sqlite3_prepare_v2(dbIns, sqlStr,  -1, &sqlStmt, NULL) != SQLITE_OK) {
                NSLog(@"Problem with prepare comic delete statement");
                return NO;
            }
            if (sqlite3_step(sqlStmt) == SQLITE_DONE) {
                NSLog(@"comic deleted locally.");
            } else {
                NSLog(@"failed to delete comic in local DB.");
            }
            sqlite3_finalize(sqlStmt);
            return YES;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot delete comic in local DB because %@", [exception reason]);
    }
    @finally {
        sqlite3_close(dbIns);
    }
}
@end
