/*
 The MIT License (MIT)

 Copyright (c) 2015-present Badoo Trading Limited.

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

#import "BRAAppDelegate.h"
#import "BRAMainViewController.h"
#import "UIViewController+Factory.h"
#import "BRAEmployeesDownloader.h"
#import "BRAPeriodicEventsService.h"
#import "BRAEmployeesUpdater.h"
#import "BRAExpiredObjectsCleaner.h"

@interface BRAAppDelegate ()
@end

@implementation BRAAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [self loadMainViewController];
    [self.window makeKeyAndVisible];

    [BRAEmployeesDownloader updateEmployees];
    [self setupPeriodicEventsService];

    return YES;
}

- (void)setupPeriodicEventsService {
    [[BRAPeriodicEventsService sharedInstance] registerEventHandler:[BRAEmployeesUpdater new]];
    [[BRAPeriodicEventsService sharedInstance] registerEventHandler:[BRAExpiredObjectsCleaner new]];
}

- (void)loadMainViewController {
    BRAMainViewController *mainViewController = [BRAMainViewController bra_controller];
    [self.window addSubview:mainViewController.view];
    self.window.rootViewController = mainViewController;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

@end
