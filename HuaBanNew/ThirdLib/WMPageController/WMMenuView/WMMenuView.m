//
//  WMMenuView.m
//  WMPageController
//
//  Created by Mark on 15/4/26.
//  Copyright (c) 2015年 yq. All rights reserved.
//

#import "WMMenuView.h"
#import "WMMenuItem.h"
#import "WMProgressView.h"
#import "WMFooldView.h"
// 导航菜单栏距边界的间距
#define WMMenuMargin 0
#define kMaskWidth   0
#define kItemWidth   60
#define kTagGap      6250
#define kBGColor     [UIColor colorWithRed:172.0/255.0 green:165.0/255.0 blue:162.0/255.0 alpha:1.0]
@interface WMMenuView () <WMMenuItemDelegate> {
    CGFloat _norSize;
    CGFloat _selSize;
    UIColor *_norColor;
    UIColor *_selColor;
}
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) WMProgressView *progressView;
@property (nonatomic, weak) WMMenuItem *selItem;
@property (nonatomic, strong) UIColor *bgColor;
@property (nonatomic, strong) NSMutableArray *frames;
@end
// 下划线的高度
static CGFloat const WMProgressHeight = 2.0;

@implementation WMMenuView

#pragma mark - Lazy
- (CGFloat)progressHeight {
    if (_progressHeight == 0.0) {
        _progressHeight = WMProgressHeight;
    }
    return _progressHeight;
}

- (UIColor *)lineColor {
    if (!_lineColor) {
        _lineColor = _selColor;
    }
    return _lineColor;
}

- (NSMutableArray *)frames {
    if (_frames == nil) {
        _frames = [NSMutableArray array];
    }
    return _frames;
}

#pragma mark - Public Methods
- (instancetype)initWithFrame:(CGRect)frame buttonItems:(NSArray *)items backgroundColor:(UIColor *)bgColor norSize:(CGFloat)norSize selSize:(CGFloat)selSize norColor:(UIColor *)norColor selColor:(UIColor *)selColor {
    if (self = [super initWithFrame:frame]) {
        _items = items;
        if (bgColor) {
            _bgColor = bgColor;
        } else {
            _bgColor = kBGColor;
        }
        _norSize  = norSize;
        _selSize  = selSize;
        _norColor = norColor;
        _selColor = selColor;
    }
    return self;
}

- (void)slideMenuAtProgress:(CGFloat)progress {
    if (self.progressView) {
        self.progressView.progress = progress;
    }
    NSInteger tag = (NSInteger)progress + kTagGap;
    CGFloat rate = progress - tag + kTagGap;
    WMMenuItem *currentItem = (WMMenuItem *)[self viewWithTag:tag];
    WMMenuItem *nextItem = (WMMenuItem *)[self viewWithTag:tag+1];
    if (rate == 0.0) {
        rate = 1.0;
        self.selItem.rate = 0;
        [self.selItem deselectedItemWithoutAnimation];
        self.selItem = currentItem;
        self.selItem.rate = 1;
        [self.selItem selectedItemWithoutAnimation];
        [self refreshContenOffset];
        return;
    }
    currentItem.rate = 1-rate;
    nextItem.rate = rate;
}

- (void)selectItemAtIndex:(NSInteger)index {
    NSInteger tag = index + kTagGap;
    NSInteger currentIndex = self.selItem.tag - kTagGap;
    WMMenuItem *item = (WMMenuItem *)[self viewWithTag:tag];
    [self.selItem deselectedItemWithoutAnimation];
    self.selItem = item;
    [self.selItem selectedItemWithoutAnimation];
    [self.progressView setProgressWithOutAnimate:index];
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:index currentIndex:currentIndex];
    }
    [self refreshContenOffset];
}

#pragma mark - Private Methods
- (void)willMoveToSuperview:(UIView *)newSuperview {
    [self addScrollView];
    [self addItems];
    [self makeStyle];
}

// 有没更好地命名
- (void)makeStyle {
    switch (self.style) {
        case WMMenuViewStyleLine:
            [self addProgressView];
            break;
        case WMMenuViewStyleFoold:
            [self addFooldViewHollow:NO];
            break;
        case WMMenuViewStyleFooldHollow:
            [self addFooldViewHollow:YES];
            break;
        default:
            break;
    }
}

// 让选中的item位于中间
- (void)refreshContenOffset {
    CGRect frame = self.selItem.frame;
    CGFloat itemX = frame.origin.x;
    CGFloat width = self.scrollView.frame.size.width;
    CGSize contentSize = self.scrollView.contentSize;
    if (itemX > width/2) {
        CGFloat targetX;
        if ((contentSize.width-itemX) <= width/2) {
            targetX = contentSize.width - width;
        } else {
            targetX = frame.origin.x - width/2 + frame.size.width/2;
        }
        // 应该有更好的解决方法
        if (targetX + width > contentSize.width) {
            targetX = contentSize.width - width;
        }
        [self.scrollView setContentOffset:CGPointMake(targetX, 0) animated:YES];
    } else {
        [self.scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
    }
}

- (void)addScrollView {
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    CGRect frame = CGRectMake(0, 0, width, height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:frame];
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator   = NO;
    scrollView.backgroundColor = self.bgColor;
    [self addSubview:scrollView];
    self.scrollView = scrollView;
}

- (void)addItems {
    [self calculateItemFrames];
    
    for (int i = 0; i < self.items.count; i++) {
        CGRect frame = [self.frames[i] CGRectValue];
        WMMenuItem *item = [[WMMenuItem alloc] initWithFrame:frame];
        item.tag = (i+kTagGap);
        item.delegate = self;
        item.text = self.items[i];
        item.textAlignment = NSTextAlignmentCenter;
        item.textColor = _norColor;
        item.userInteractionEnabled = YES;
        if (self.fontName) {
            item.font = [UIFont fontWithName:self.fontName size:_selSize];
        } else {
            item.font = [UIFont systemFontOfSize:_selSize];
        }
        item.backgroundColor = [UIColor clearColor];
        item.normalSize    = _norSize;
        item.selectedSize  = _selSize;
        item.normalColor   = _norColor;
        item.selectedColor = _selColor;
        if (i == 0) {
            [item selectedItemWithoutAnimation];
            self.selItem = item;
        } else {
            [item deselectedItemWithoutAnimation];
        }
        [self.scrollView addSubview:item];
    }
}

// 计算所有item的frame值，主要是为了适配所有item的宽度之和小于屏幕宽的情况
// 这里与后面的 `-addItems` 做了重复的操作，并不是很合理
- (void)calculateItemFrames {
    CGFloat contentWidth = WMMenuMargin;
    for (int i = 0; i < self.items.count; i++) {
        CGFloat itemW = kItemWidth;
        if ([self.delegate respondsToSelector:@selector(menuView:widthForItemAtIndex:)]) {
            itemW = [self.delegate menuView:self widthForItemAtIndex:i];
        }
        CGRect frame = CGRectMake(contentWidth, 0, itemW, self.frame.size.height);
        // 记录frame
        [self.frames addObject:[NSValue valueWithCGRect:frame]];
        contentWidth += itemW;
    }
    contentWidth += WMMenuMargin;
    // 如果总宽度小于屏幕宽,重新计算frame,为item间添加间距
    if (contentWidth < self.frame.size.width) {
        // 计算间距
        CGFloat distance = self.frame.size.width - contentWidth;
        CGFloat gap = distance / (self.items.count + 1);
        for (int i = 0; i < self.frames.count; i++) {
            CGRect frame = [self.frames[i] CGRectValue];
            frame.origin.x += gap * (i+1);
            self.frames[i] = [NSValue valueWithCGRect:frame];
        }
        contentWidth = self.frame.size.width;
    }
    self.scrollView.contentSize = CGSizeMake(contentWidth, self.frame.size.height);
}

// MARK:Progress View
- (void)addProgressView {
    WMProgressView *pView = [[WMProgressView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - self.progressHeight, self.scrollView.contentSize.width, self.progressHeight)];
    pView.itemFrames = self.frames;
    pView.color = self.lineColor.CGColor;
    pView.backgroundColor = [UIColor clearColor];
    self.progressView = pView;
    [self.scrollView addSubview:pView];
}

- (void)addFooldViewHollow:(BOOL)isHollow {
    WMFooldView *fooldView = [[WMFooldView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.contentSize.width, self.frame.size.height)];
    fooldView.itemFrames = self.frames;
    fooldView.color = self.lineColor.CGColor;
    fooldView.hollow = isHollow;
    fooldView.backgroundColor = [UIColor clearColor];
    self.progressView = fooldView;
    [self.scrollView insertSubview:fooldView atIndex:0];
}

#pragma mark - Menu item delegate
- (void)didPressedMenuItem:(WMMenuItem *)menuItem {
    if (self.selItem == menuItem) return;
    
    CGFloat progress = menuItem.tag - kTagGap;
    [self.progressView moveToPostion:progress];
    
    NSInteger currentIndex = self.selItem.tag - kTagGap;
    if ([self.delegate respondsToSelector:@selector(menuView:didSelesctedIndex:currentIndex:)]) {
        [self.delegate menuView:self didSelesctedIndex:menuItem.tag-kTagGap currentIndex:currentIndex];
    }
    
    menuItem.selected = YES;
    self.selItem.selected = NO;
    self.selItem = menuItem;
    // 让选中的item位于中间
    [self refreshContenOffset];
}

@end
