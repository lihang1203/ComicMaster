//
//  CMGenericDAO.m
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import "CMGenericDAO.h"

NSString * const LOCAL_DB_NAME = @"ComicMasterDB.sqlite";

@implementation CMGenericDAO

- (BOOL)openDB:(NSString *)dbName
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *dbPath = [documentsDirectory stringByAppendingPathComponent:dbName];
    BOOL success = [fileMgr fileExistsAtPath:dbPath];
    if(!success)
    {
        // copy the sqlite to document directory if haven't
        NSString *dbBundlePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:dbName];
        NSError *error;
        if(![fileMgr copyItemAtPath:dbBundlePath toPath:[NSString stringWithFormat:@"%@/Documents/ComicMasterDB.sqlite", NSHomeDirectory()] error:&error]) {
            NSLog(@"Error creating the database: %@", [error description]);
        }
        // still not work, then something wrong..
        dbPath = [documentsDirectory stringByAppendingPathComponent:dbName];
        if (![fileMgr fileExistsAtPath:dbPath]) {
            NSLog(@"Cannot locate database file '%@'.", dbPath);
            return NO;
        }
    }
    // open the DB
    if(!(sqlite3_open([dbPath UTF8String], &dbIns) == SQLITE_OK))
    {
        NSLog(@"An error has occured while openning DB.");
        return NO;
    }
    return YES;
}

@end
