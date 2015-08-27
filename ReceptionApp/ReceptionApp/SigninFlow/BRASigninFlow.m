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

#import "BRASigninFlow.h"
#import "BRAVisitor.h"
#import "BRARepository+VisitorAdditions.h"
#import "BRAPrinter.h"
#import "BRAMailManager.h"
#import "BRAPDFRenderOperation.h"

NSString *const BRASigninExpiredNotification = @"BRASigninExpiredNotification";

@interface BRASigninFlow ()
@property (nonatomic, strong, readwrite) BRAVisitor *currentVisitor;
@property (nonatomic, strong) NSTimer *expiryTimer;
@property (nonatomic, strong) BRAPrinter *printer;
@end

@implementation BRASigninFlow

+ (NSUInteger)minutesToWaitForActivityBeforeExpire {
    return 3;
}

+ (instancetype)sharedInstance {
    static BRASigninFlow *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BRASigninFlow alloc] init];
    });
    return sharedInstance;
}

- (void)registerUserAction {
    [self scheduleTimer];
}

- (void)startFlow {
    self.currentVisitor = [BRAVisitor new];
    [self scheduleTimer];
}

- (void)finishFlowWithBadgeImage:(UIImage *)badgeImage {
    [self.expiryTimer invalidate];
    [[BRARepository sharedInstance] saveVisitor:self.currentVisitor];
    [self printBadge:badgeImage];

    BRAPDFRenderOperation *pdfRenderOperation = [BRAPDFRenderOperation operationWithVisitor:self.currentVisitor];
    @weakify(self);
    pdfRenderOperation.completionBlock = ^ {
        @strongify(self);
        [BRAMailManager sendEmailWithVisitor:self.currentVisitor badgeImage:badgeImage];
    };
    [[NSOperationQueue mainQueue] addOperation:pdfRenderOperation];
}

- (void)printBadge:(UIImage *)badgeImage {
    self.printer = [BRAPrinter printer];
    [self.printer printBadgeImage:badgeImage];
}

- (void)scheduleTimer {
    [self.expiryTimer invalidate];
    self.expiryTimer = [NSTimer scheduledTimerWithTimeInterval:[[self class] minutesToWaitForActivityBeforeExpire] * 60.0f
                                                        target:self
                                                      selector:@selector(signinExpired:)
                                                      userInfo:nil
                                                       repeats:NO];
}

- (void)signinExpired:(id)signinExpired {
    [[NSNotificationCenter defaultCenter] postNotificationName:BRASigninExpiredNotification object:nil];
}

@end
