//
//  MSTableViewController.m
//  BGChain
//
//  Created by Micker on 2020/7/29.
//  Copyright © 2020 Micker. All rights reserved.
//

#import "MSTableViewController.h"
#import "MExcelView.h"

@interface MSTableViewController ()<MExcelViewDelegate>

@end

@implementation MSTableViewController {
    NSArray *_TITLES;
    NSArray *_WIDTHS;
    NSMutableArray *_scrollViews;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _TITLES = @[@"基金名称",@"净值",@"日涨幅",@"近1月",@"近3月",@"近1年",@"近3年",@"成立以来",@"规模",@"同类排名"];
    _WIDTHS = @[@(150),@(60),@(60),@(60),@(60),@(60),@(60),@(60),@(60),@(60)];
    _scrollViews = [NSMutableArray arrayWithCapacity:1];
    [self.tableView registerClass:[MExcelTableViewCell class] forCellReuseIdentifier:@"MExcelTableViewCell"];
    [self.tableView registerClass:[MExcelTableViewHeaderView class] forHeaderFooterViewReuseIdentifier:@"MExcelTableViewHeaderView"];
    
    [self.tableView reloadData];
    
    self.view.backgroundColor = [UIColor whiteColor];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MExcelTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MExcelTableViewCell"];
    
    cell.excelView.items = _TITLES;
    cell.excelView.fixdIndexs = @[@(0)];
    cell.excelView.delegate = self;
    cell.excelEdgeInsets = UIEdgeInsetsMake(15, 10, 15, 10);
    __weak typeof(self) weakSelf = self;
    cell.excelView.presentBlock = ^id (NSUInteger index) {
        __strong typeof(self) strongSelf = weakSelf;
        CATextLayer *layer = [CATextLayer new];
        layer.string = strongSelf->_TITLES[index];
        layer.fontSize = 14;
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.foregroundColor = (1 == index%2) ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        return layer;
    };
    cell.excelView.widthBlock = ^CGFloat(NSUInteger index) {
        __strong typeof(self) strongSelf = weakSelf;
        return [strongSelf->_WIDTHS[index] floatValue];
    };
    [cell.excelView reloadData];
    [_scrollViews addObject:cell.excelView.rightScrollView];
    return cell;
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    MExcelTableViewHeaderView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"MExcelTableViewHeaderView"];
    view.backgroundColor = [UIColor whiteColor];
    view.excelView.items = _TITLES;
    view.excelView.fixdIndexs = @[@(0)];
    view.excelView.delegate = self;
    view.excelEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10);
    __weak typeof(self) weakSelf = self;
    view.excelView.presentBlock = ^id (NSUInteger index) {
        __strong typeof(self) strongSelf = weakSelf;
        CATextLayer *layer = [CATextLayer new];
        layer.string = strongSelf->_TITLES[index];
        layer.fontSize = 14;
        layer.contentsScale = [UIScreen mainScreen].scale;
        layer.foregroundColor = (1 == index%2) ? [UIColor greenColor].CGColor : [UIColor redColor].CGColor;
        return layer;
    };
    view.excelView.widthBlock = ^CGFloat(NSUInteger index) {
        __strong typeof(self) strongSelf = weakSelf;
        return [strongSelf->_WIDTHS[index] floatValue];
    };
    
    [view.excelView reloadData];
    [_scrollViews addObject:view.excelView.rightScrollView];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (void) internalScrollViewDidScroll:(UIScrollView *)scrollView {
    [_scrollViews enumerateObjectsUsingBlock:^(UIScrollView *view, NSUInteger idx, BOOL * _Nonnull stop) {
        if (scrollView != view) {
            [view setContentOffset:scrollView.contentOffset];
        }
    }];
}
@end

