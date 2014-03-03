//
//  CLAppDelegate.m
//  CLog
//
//  Created by Christoph Lückler on 03.03.14.
//  Copyright (c) 2014 Up To Eleven. All rights reserved.
//

#import "CLAppDelegate.h"

@implementation CLAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    return YES;
}

@end
