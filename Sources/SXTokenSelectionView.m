#import "SXTokenSelectionView.h"

@interface SXTokenSelectionView ()
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *tokenButtons;
@property (nonatomic, assign) NSInteger nextSelectionOrder;
@property (nonatomic, strong) UIPanGestureRecognizer *selectionPanGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *handleLongPressGesture;
@property (nonatomic, assign) BOOL panSelectionState;
@property (nonatomic, assign) NSInteger panAnchorIndex;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *panInitialSelectionStates;
@end

@implementation SXTokenSelectionView

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        _tokenBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        _tokenTextColor = UIColor.whiteColor;
        _selectedTokenBackgroundColor = [UIColor systemBlueColor];
        _selectedTokenTextColor = UIColor.whiteColor;
        _tokenButtons = [NSMutableArray array];
        _nextSelectionOrder = 0;
        _panInitialSelectionStates = [NSMutableArray array];
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews {
    self.scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.scrollView];

    self.tokenSelectionSearchButton = [self accessoryButtonWithSystemName:@"magnifyingglass"];
    self.tokenSelectionClearButton  = [self accessoryButtonWithSystemName:@"xmark.circle"];
    self.tokenSelectionResetButton  = [self accessoryButtonWithSystemName:@"arrow.counterclockwise"];

    self.selectionPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                      action:@selector(handleSelectionPan:)];
    [self addGestureRecognizer:self.selectionPanGesture];
    self.handleLongPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                                               action:@selector(handleLongPressGesture:)];
    [self addGestureRecognizer:self.handleLongPressGesture];
}

- (UIButton *)accessoryButtonWithSystemName:(NSString *)name {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    UIImage *img = [UIImage systemImageNamed:name];
    [b setImage:img forState:UIControlStateNormal];
    b.tintColor = UIColor.labelColor;
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [self addSubview:b];
    return b;
}

#pragma mark - 构建

- (void)setItems:(NSArray<SXTokenItem *> *)items {
    _items = [items copy];
    [self rebuildTokenButtons];
}

- (void)rebuildTokenButtons {
    for (UIButton *b in self.tokenButtons) [b removeFromSuperview];
    [self.tokenButtons removeAllObjects];

    CGFloat x = 8, y = 8, maxW = CGRectGetWidth(self.bounds) - 16;
    UIFont *f = [UIFont systemFontOfSize:14];
    for (NSUInteger i = 0; i < self.items.count; i++) {
        SXTokenItem *it = self.items[i];
        CGSize size = [it.text sizeWithAttributes:@{NSFontAttributeName: f}];
        CGFloat w = size.width + 20, h = 30;
        if (x + w > maxW) { x = 8; y += h + 6; }
        UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
        b.frame = CGRectMake(x, y, w, h);
        b.tag = i;
        b.titleLabel.font = f;
        [b setTitle:it.text forState:UIControlStateNormal];
        b.layer.cornerRadius = 8;
        b.layer.masksToBounds = YES;
        [b addTarget:self action:@selector(handleTokenTap:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:b];
        [self.tokenButtons addObject:b];
        it.buttonIndex = i;
        [self updateAppearanceForItem:it];
        x += w + 6;
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.bounds), y + 38 + 8);
}

- (void)updateAppearanceForItem:(SXTokenItem *)it {
    if (it.buttonIndex < 0 || it.buttonIndex >= (NSInteger)self.tokenButtons.count) return;
    UIButton *b = self.tokenButtons[it.buttonIndex];
    b.backgroundColor = it.selected ? self.selectedTokenBackgroundColor : self.tokenBackgroundColor;
    [b setTitleColor:it.selected ? self.selectedTokenTextColor : self.tokenTextColor
            forState:UIControlStateNormal];
}

- (void)handleTokenTap:(UIButton *)sender {
    SXTokenItem *it = self.items[sender.tag];
    [self updateSelectionOrderForItem:it wasSelected:!it.selected];
    [self updateAppearanceForItem:it];
    if ([self.delegate respondsToSelector:@selector(tokenSelectionDidChange:)])
        [self.delegate tokenSelectionDidChange:self.items];
}

#pragma mark - 选择顺序

- (void)updateSelectionOrderForItem:(SXTokenItem *)it wasSelected:(BOOL)selected {
    it.selected = selected;
    if (selected) {
        it.order = self.nextSelectionOrder++;
    } else {
        NSInteger removed = it.order;
        it.order = -1;
        // 后续顺序整体前移
        for (SXTokenItem *o in self.items)
            if (o.order > removed) o.order -= 1;
        self.nextSelectionOrder = MAX(0, self.nextSelectionOrder - 1);
    }
}

- (void)shiftSelectionOrdersAfterOrder:(NSInteger)order by:(NSInteger)delta
                            excludingItem:(SXTokenItem *)exclude {
    for (SXTokenItem *o in self.items) {
        if (o == exclude) continue;
        if (o.order > order) o.order += delta;
    }
}

- (NSString *)composedText {
    NSArray *sorted = [self.items sortedArrayUsingComparator:^NSComparisonResult(SXTokenItem *a, SXTokenItem *b) {
        return [@(a.order) compare:@(b.order)];
    }];
    NSMutableString *s = [NSMutableString string];
    for (SXTokenItem *it in sorted) if (it.selected) [s appendString:it.text];
    return s;
}

#pragma mark - 命中测试

- (NSInteger)indexOfTokenAtPoint:(CGPoint)p {
    for (UIButton *b in self.tokenButtons) {
        if (CGRectContainsPoint(b.frame, p)) return b.tag;
    }
    return -1;
}

- (SXTokenItem *)tokenAtPoint:(CGPoint)p inView:(UIView *)v {
    CGPoint local = [v convertPoint:p toView:self];
    NSInteger i = [self indexOfTokenAtPoint:local];
    return (i >= 0 && i < (NSInteger)self.items.count) ? self.items[i] : nil;
}

- (BOOL)containsTokenAtPoint:(CGPoint)p {
    return [self indexOfTokenAtPoint:[self convertPoint:p fromView:self.superview]] >= 0;
}

- (void)refineTokenAtPoint:(CGPoint)p {
    NSInteger i = [self indexOfTokenAtPoint:p];
    if (i < 0) return;
    SXTokenItem *it = self.items[i];
    [self updateSelectionOrderForItem:it wasSelected:!it.selected];
    [self updateAppearanceForItem:it];
}

#pragma mark - 手势

- (void)handleSelectionPan:(UIPanGestureRecognizer *)g {
    CGPoint p = [g locationInView:self];
    switch (g.state) {
        case UIGestureRecognizerStateBegan: {
            [self capturePanInitialSelectionStates];
            self.panAnchorIndex = [self indexOfTokenAtPoint:p];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            NSInteger i = [self indexOfTokenAtPoint:p];
            if (i >= 0) [self applyPanSelectionToIndex:i];
            break;
        }
        default: {
            self.panSelectionState = NO;
            if ([self.delegate respondsToSelector:@selector(tokenSelectionDidChange:)])
                [self.delegate tokenSelectionDidChange:self.items];
            break;
        }
    }
}

- (void)capturePanInitialSelectionStates {
    [self.panInitialSelectionStates removeAllObjects];
    for (SXTokenItem *it in self.items)
        [self.panInitialSelectionStates addObject:@(it.selected)];
}

- (void)applyPanSelectionToIndex:(NSInteger)index {
    NSInteger lo = MIN(self.panAnchorIndex, index), hi = MAX(self.panAnchorIndex, index);
    if (lo < 0) return;
    for (NSInteger i = lo; i <= hi && i < (NSInteger)self.items.count; i++) {
        SXTokenItem *it = self.items[i];
        BOOL target = self.panInitialSelectionStates.count > (NSUInteger)i
                    ? [self.panInitialSelectionStates[i] boolValue] : YES;
        if (it.selected != target) [self updateSelectionOrderForItem:it wasSelected:target];
        [self updateAppearanceForItem:it];
    }
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)g {
    if (g.state != UIGestureRecognizerStateBegan) return;
    CGPoint p = [g locationInView:self];
    [self refineTokenAtPoint:p];
}

#pragma mark - 模式与尺寸

- (void)toggleTokenSelectionMode {
    self.tokenSelectionModeEnabled = !self.tokenSelectionModeEnabled;
}

- (CGFloat)tokenHeightForText:(NSString *)text { return 30.0; }

- (CGFloat)tokenWidthForDisplayText:(NSString *)display tokenText:(NSString *)token maxWidth:(CGFloat)maxW {
    CGSize s = [display sizeWithAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14]}];
    return MIN(s.width + 20, maxW);
}

- (CGFloat)tokenSelectionContentWidthForContentWidth:(CGFloat)w { return w; }
- (CGRect)tokenSelectionFrameForContentFrame:(CGRect)f { return f; }
- (CGFloat)tokenSelectionAccessoryButtonsHeight { return 38.0; }
- (CGFloat)tokenSelectionAccessoryButtonWidthForButtonHeight:(CGFloat)h { return h; }

- (CGFloat)estimatedTokenSelectionContentHeightForText:(NSString *)t contentWidth:(CGFloat)w {
    CGFloat x = 8, y = 8;
    UIFont *f = [UIFont systemFontOfSize:14];
    for (SXTokenItem *it in self.items) {
        CGFloat tw = [it.text sizeWithAttributes:@{NSFontAttributeName: f}].width + 20;
        if (x + tw > w - 8) { x = 8; y += 36; }
        x += tw + 6;
    }
    return y + 30 + 46;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat h = 38, bw = 30, pad = 8;
    self.tokenSelectionClearButton.frame  = CGRectMake(CGRectGetWidth(self.bounds) - pad - bw, pad, bw, h);
    self.tokenSelectionResetButton.frame  = CGRectMake(CGRectGetWidth(self.bounds) - pad*2 - bw*2, pad, bw, h);
    self.tokenSelectionSearchButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - pad*3 - bw*3, pad, bw, h);
    self.scrollView.frame = CGRectMake(0, 38, CGRectGetWidth(self.bounds),
                                       MAX(0, CGRectGetHeight(self.bounds) - 38));
}

@end
