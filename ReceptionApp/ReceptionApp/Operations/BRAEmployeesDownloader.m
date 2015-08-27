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

#import "BRAEmployeesDownloader.h"
#import "BRASettingsManager.h"
#import "BRAEmployee+DictionarySupport.h"
#import "BRARepository.h"

@interface BRAEmployeesDownloader ()
@end

@implementation BRAEmployeesDownloader

#pragma mark - Constants

+ (NSString *)employeesJSONKey {
    return @"employees";
}

+ (void)updateEmployees {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void) {
        [self _updateEmployees];
    });
}

+ (void)_updateEmployees {
    NSData *data = [self requestEmployeesList];
    NSDictionary *jsonDictionary = [self jsonDictionaryFromData:data];
    NSArray *employees = [self createEmployeesFromDictionary:jsonDictionary];
    [self saveEmployeesToRepository:employees];
}

#pragma mark - Custom Logic

+ (NSData *)requestEmployeesList {
    NSString *employeesURLString = [[BRASettingsManager sharedInstance] employeeFileURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:employeesURLString]];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        [self reportError:error];
        return nil;
    }
    return data;
}

+ (NSDictionary *)jsonDictionaryFromData:(NSData *)data {
    if (data == nil) {
        return nil;
    }

    NSError *deserializationError = nil;
    NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&deserializationError];
    if (deserializationError) {
        [self reportError:deserializationError];
        return nil;
    }

    return jsonDictionary;
}

+ (NSArray *)createEmployeesFromDictionary:(NSDictionary *)jsonDictionary {
    if (jsonDictionary == nil) {
        return nil;
    }

    NSMutableArray *employees = [NSMutableArray new];
    NSArray *employeesDicts = jsonDictionary[[[self class] employeesJSONKey]];
    for (NSDictionary *employeeDict in employeesDicts) {
        [employees addObject:[BRAEmployee employeeWithDictionary:employeeDict]];
    }

    return [employees copy];
}

+ (void)saveEmployeesToRepository:(NSArray *)employees {
    if ([employees count] == 0) {
        return;
    }

    [[BRARepository sharedInstance] removeAllObjectsOfClass:[BRAEmployee class]];
    for (BRAEmployee *employee in employees) {
        [[BRARepository sharedInstance] saveObject:employee];
    }
}

+ (void)reportError:(NSError *)error {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", nil)
                                    message:[error localizedDescription]
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"I understand", nil)
                          otherButtonTitles:nil] show];
    });
}

@end