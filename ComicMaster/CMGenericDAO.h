//
//  CMGenericDAO.h
//  ComicMaster
//
//  Created by Hang Li on 8/10/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

extern NSString * const LOCAL_DB_NAME;

@interface CMGenericDAO : NSObject
{
    sqlite3 *dbIns;
}

- (BOOL) openDB:(NSString *)dbName;

@end
