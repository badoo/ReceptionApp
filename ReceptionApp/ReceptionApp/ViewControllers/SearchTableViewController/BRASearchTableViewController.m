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

#import <Haneke/UIImageView+Haneke.h>
#import "BRASearchTableViewController.h"
#import "BRAsearchTableViewCell.h"
#import "BRASearchEmployeesDataSource.h"

@interface BRASearchTableViewController ()
@end

@implementation BRASearchTableViewController

- (instancetype)initWithCompletionBlock:(BRASearchCompletionBlock)completionBlock {
    if (self = [super init]) {
        _completionBlock = [completionBlock copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.rowHeight = 60;
    self.tableView.tableFooterView = [UIView new];
    self.tableView.delegate = self;
    self.tableView.dataSource = self.searchDataSource;
    [self.tableView registerClass:[BRASearchTableViewCell class] forCellReuseIdentifier:[BRASearchEmployeesDataSource cellIdentifier]];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[BRASearchEmployeesDataSource notFoundCellIdentifier]];
}

- (void)dealloc {
    self.tableView.dataSource = nil;
    self.tableView.delegate = nil;
}

- (void)nameDidChange:(NSString *)name {
    NSAssert(self.searchDataSource, @"You need to attach datasource");
    if (self.searchDataSource) {
        [self.searchDataSource textDidChange:name];
        [self.tableView reloadData];
    }
}

#pragma mark - Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.completionBlock != nil) {
        if (indexPath.section == 1) {
            BRAEmployee *employee = [self.searchDataSource objectAtIndexPath:indexPath];
            self.completionBlock(employee);
        }
    }
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.imageView hnk_cancelSetImage];
}

@end
