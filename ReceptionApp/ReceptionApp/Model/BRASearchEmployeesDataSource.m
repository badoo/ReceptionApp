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

#import "BRASearchEmployeesDataSource.h"
#import "BRASearchTableViewCell+Employee.h"
#import "BRARepository.h"

@interface BRASearchEmployeesDataSource ()
@property (nonatomic, copy) NSArray *employees;
@property (nonatomic, copy) NSArray *filteredEmployees;
@end

@implementation BRASearchEmployeesDataSource

- (NSArray *)employees {
    if (_employees == nil) {
        _employees = [[BRARepository sharedInstance] allObjectsOfClass:[BRAEmployee class]];
    }
    return _employees;
}

- (NSArray *)filteredEmployees {
    if (_filteredEmployees == nil) {
        _filteredEmployees = self.employees;
    }
    return _filteredEmployees;
}

#pragma mark - UITableViewDataSource

+ (NSString *)cellIdentifier {
    return @"searchCellIdentifier";
}

+ (NSString *)notFoundCellIdentifier {
    return @"notFoundCellIdentifier";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.filteredEmployees.count ? 0 : 1;
    }
    return self.filteredEmployees.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        UITableViewCell *notFoundCell = [tableView dequeueReusableCellWithIdentifier:[[self class] notFoundCellIdentifier]];
        notFoundCell.textLabel.text = NSLocalizedString(@"Not found", nil);
        return notFoundCell;
    }
    
    BRASearchTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[[self class]cellIdentifier]];
    BRAEmployee *selectedEmployee = self.filteredEmployees[(NSUInteger) indexPath.row];
    [cell configureWithEmployee:selectedEmployee];

    return cell;
}

#pragma mark - BRASearchProviderProtocol

- (void)textDidChange:(NSString *)text {
    if (text.length == 0) {
        self.filteredEmployees = self.employees;
    } else {
        NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"nameAndSurname CONTAINS[cd] %@", text];
        self.filteredEmployees = [self.employees filteredArrayUsingPredicate:searchPredicate];
    }
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
    return self.filteredEmployees[(NSUInteger) indexPath.row];
}

@end
