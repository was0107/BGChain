//
//  MExcelView.h
//  BGChain
//
//  Created by Micker on 2020/7/29.
//  Copyright © 2020 Micker. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MExcelViewDelegate <NSObject>

@optional

- (void) internalScrollViewDidScroll:(UIScrollView *)scrollView;

@end

@interface MExcelView : UIView
@property (nonatomic, strong) NSArray *items;
@property (nonatomic, strong) NSArray *fixdIndexs;
@property (nonatomic, weak) id<MExcelViewDelegate> delegate;
@property (nonatomic, strong, readonly) UIScrollView *rightScrollView;
@property (nonatomic, copy) CGFloat (^widthBlock)(NSUInteger index);
@property (nonatomic, copy) id (^presentBlock)(NSUInteger index);

- (void) reloadData;

@end



@interface MExcelTableViewCell : UITableViewCell
@property (nonatomic, assign) UIEdgeInsets excelEdgeInsets;
@property (nonatomic, strong) MExcelView *excelView;

@end


@interface MExcelTableViewHeaderView : UITableViewHeaderFooterView
@property (nonatomic, assign) UIEdgeInsets excelEdgeInsets;
@property (nonatomic, strong) MExcelView *excelView;
@end

