//
//  MExcelView.m
//  BGChain
//
//  Created by Micker on 2020/7/29.
//  Copyright © 2020 Micker. All rights reserved.
//

#import "MExcelView.h"

@interface MExcelView()<UIScrollViewDelegate>
@property (nonatomic, strong) NSMutableDictionary *cachedViewWidth;
@property (nonatomic, strong) UIScrollView *rightScrollView;

@end

@implementation MExcelView {
    NSMutableArray *_layerViews;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _layerViews = [NSMutableArray arrayWithCapacity:10];
        [self addSubview:self.rightScrollView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    
    CGFloat height = CGRectGetHeight(self.bounds);
    __block CGFloat width = 0;
    
    [self.fixdIndexs enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSUInteger index = [obj unsignedIntegerValue];
        CGFloat itemWidth = [[self.cachedViewWidth valueForKey: [NSString stringWithFormat:@"%@",@(index)]] floatValue];
        id content = (nil == self.presentBlock)?nil:self.presentBlock(index);
        if (content) {
            if ([content isKindOfClass: [CALayer class]]) {
                CALayer *layer = content;
                layer.frame = CGRectMake(width, 0, itemWidth, height);
                layer.zPosition = 1;
                [self.layer addSublayer:layer];
                [_layerViews addObject:layer];
            } else {
                UIView *view = content;
                view.frame = CGRectMake(width, 0, itemWidth, height);
                [self addSubview:view];
                [_layerViews addObject:view];
            }
            width += itemWidth;
        }
        
    }];
    
    [self.rightScrollView setFrame:CGRectMake(width, 0, CGRectGetWidth(self.bounds) - width, height)];
    width = 0;
    
    [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if(![self.fixdIndexs containsObject:@(idx)]) {
            NSUInteger index = idx;
            CGFloat itemWidth = [[self.cachedViewWidth valueForKey: [NSString stringWithFormat:@"%@",@(index)]] floatValue];
            id content = (nil == self.presentBlock)?nil:self.presentBlock(index);
            if (content) {
                if ([content isKindOfClass: [CALayer class]]) {
                    CALayer *layer = content;
                    layer.frame = CGRectMake(width, 0, itemWidth, height);
                    [self.rightScrollView.layer addSublayer:layer];
                    [_layerViews addObject:layer];

                } else {
                    UIView *view = content;
                    view.frame = CGRectMake(width, 0, itemWidth, height);
                    [self.rightScrollView addSubview:view];
                    [_layerViews addObject:view];

                }
                width += itemWidth;
            }
        }
      }];
    
    [self.rightScrollView setContentSize:CGSizeMake(width, height)];
}

- (NSMutableDictionary *) cachedViewWidth {
    if (!_cachedViewWidth) {
        _cachedViewWidth = [NSMutableDictionary dictionary];
    }
    return _cachedViewWidth;
}

- (UIScrollView *) rightScrollView {
    if (!_rightScrollView) {
        _rightScrollView = [UIScrollView new];
        _rightScrollView.showsVerticalScrollIndicator = NO;
        _rightScrollView.showsHorizontalScrollIndicator = NO;
        _rightScrollView.delegate = self;
        _rightScrollView.userInteractionEnabled = NO;
        [self addGestureRecognizer:_rightScrollView.panGestureRecognizer];
    }
    return _rightScrollView;
}

- (void) reloadData {
    [self.cachedViewWidth removeAllObjects];

    [_layerViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass: [CALayer class]]) {
            [obj removeFromSuperlayer];
        } else {
            [obj removeFromSuperview];
        }
    }];
    
    if (self.delegate) {
        __block CGFloat width = 0;
        [self.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            width = (nil == self.widthBlock)? 0 :self.widthBlock(idx);
            [self.cachedViewWidth setValue:@(width) forKey: [NSString stringWithFormat:@"%@",@(idx)]];
        }];
    }
    
    [self setNeedsLayout];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(internalScrollViewDidScroll:)]) {
        [self.delegate internalScrollViewDidScroll:scrollView];
    }
}
@end

@implementation MExcelTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.excelView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.excelView.frame = UIEdgeInsetsInsetRect(self.bounds, self.excelEdgeInsets);
}

- (MExcelView *) excelView {
    if (!_excelView) {
        _excelView = [MExcelView new];
    }
    return _excelView;
}

@end


@implementation MExcelTableViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addSubview:self.excelView];
    }
    return self;
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.excelView.frame = UIEdgeInsetsInsetRect(self.bounds, self.excelEdgeInsets);
}

- (MExcelView *) excelView {
    if (!_excelView) {
        _excelView = [MExcelView new];
    }
    return _excelView;
}

@end

