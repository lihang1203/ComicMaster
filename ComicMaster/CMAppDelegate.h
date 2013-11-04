//
//  CMAppDelegate.h
//  ComicMaster
//
//  Created by Hang Li on 8/8/13.
//  Copyright (c) 2013 Hang Li. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMUser.h"
#import "KeychainItemWrapper.h"

@interface CMAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CMUser *loginUser;
@property (strong, nonatomic) KeychainItemWrapper *keyChainItem;

@end
