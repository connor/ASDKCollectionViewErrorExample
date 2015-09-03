//
//  AppDelegate.m
//  ASDKCollectionViewDemo
//
//  Created by Connor Montgomery on 9/3/15.
//  Copyright (c) 2015 Connor Montgomery. All rights reserved.
//

#import "AppDelegate.h"
#import "ASDKViewController.h"
#import "AppKitViewController.h"

#define USE_ASDK 1

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    UIViewController *viewController;

    if (USE_ASDK) {
        viewController = (ASDKViewController *)[[ASDKViewController alloc] init];
    } else {
        viewController = (AppKitViewController *)[[AppKitViewController alloc] init];
    }

    self.window.rootViewController = viewController;
    [self.window makeKeyAndVisible];

    return YES;
}

@end
