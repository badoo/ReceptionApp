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

#import "BRAPerson.h"

@implementation BRAPerson

#pragma mark - NSCoding

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.name
                  forKey:NSStringFromSelector(@selector(name))];
    [aCoder encodeObject:self.surname
                  forKey:NSStringFromSelector(@selector(surname))];
    [aCoder encodeObject:self.email
                  forKey:NSStringFromSelector(@selector(email))];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        _name = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(name))];
        _surname = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(surname))];
        _email = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(email))];
    }
    return self;
}

@end


@implementation BRAPerson (BRAConvenience)

- (NSString *)nameAndSurname {
    if ([self.surname length] > 0) {
        return [NSString stringWithFormat:@"%@ %@", self.name, self.surname];
    } else {
        return self.name;
    }
}

@end