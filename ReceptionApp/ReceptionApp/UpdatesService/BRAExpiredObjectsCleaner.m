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

#import "BRAExpiredObjectsCleaner.h"
#import "BRAMailManager.h"
#import "BRARepository+VisitorAdditions.h"
#import "NSDate+TodayDay.h"

NSString * const BRAExpiredVisitorsWereRemovedNotificationName = @"BRAExpiredVisitorsWereRemovedNotification";

@implementation BRAExpiredObjectsCleaner

+ (NSInteger)checkForExpiryHour {
    return 6;
}

#pragma mark - BRAUpdateHandlerProtocol

- (NSString *)key {
    return @"ExpiredObjectsCleaner";
}

- (BOOL)shouldScheduleNextEvent {
    return YES;
}

- (NSDate *)nextEventDate {
    NSDate *now = [NSDate date];

    NSDateComponents *tomorrowComponents = [NSDateComponents new];
    if ([now bra_hour] >= [[self class] checkForExpiryHour]) {
        tomorrowComponents.day = 1;
    }
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *nextDate = [calendar dateByAddingComponents:tomorrowComponents toDate:now options:0];

    NSDateComponents *nextDateAt6AMComponents = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:nextDate];
    nextDateAt6AMComponents.hour = [[self class] checkForExpiryHour];
    NSDate *nextDateAt6AM = [calendar dateFromComponents:nextDateAt6AMComponents];
    return nextDateAt6AM;
}

- (void)handleEventAtDate:(NSDate *)eventDate {
    NSArray *signedInVisitors = [[BRARepository sharedInstance] signedInVisitors];
    if ([signedInVisitors count]) {
        [BRAMailManager sendSignInReportWithVisitors:signedInVisitors];
    }
    [[BRARepository sharedInstance] clearExpiredObjects];
    [[NSNotificationCenter defaultCenter] postNotificationName:BRAExpiredVisitorsWereRemovedNotificationName object:nil];
}

@end