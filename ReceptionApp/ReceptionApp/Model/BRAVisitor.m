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

#import "BRAVisitor.h"
#import "NSDate+TodayDay.h"

@implementation BRAVisitor

#pragma mark - BRAVisitorProtocol

+ (NSString *)version {
    return @"1.1";
}

- (NSString *)key {
    NSTimeInterval interval = [self.date timeIntervalSince1970];
    NSString *key = [NSString stringWithFormat:@"%f", interval];
    return key;
}

- (BOOL)isExpired {
    if (self.date == nil) {
        return NO;
    }
    return [self.date bra_day] != [[NSDate date] bra_day];
}

#pragma mark - NSCoding protocol

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:self.company
                  forKey:NSStringFromSelector(@selector(company))];
    [aCoder encodeObject:self.employee
                  forKey:NSStringFromSelector(@selector(employee))];
    [aCoder encodeObject:self.profilePhoto
                  forKey:NSStringFromSelector(@selector(profilePhoto))];
    [aCoder encodeObject:self.signature
                  forKey:NSStringFromSelector(@selector(signature))];
    [aCoder encodeObject:self.date
                  forKey:NSStringFromSelector(@selector(date))];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        _company = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(company))];
        _employee = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(employee))];
        _profilePhoto = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(profilePhoto))];
        _signature = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(signature))];
        _date = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(date))];
    }
    return self;
}


@end
