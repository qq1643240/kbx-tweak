#import "SXPasteboardActionButton.h"
#import "SXConfig.h"
#import "SXConstants.h"

@interface SXPasteboardActionButton ()
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) CAGradientLayer *gradient;
@property (nonatomic, strong) NSTimer *pasteboardActionTimer;
@property (nonatomic, assign) NSInteger lastPasteboardChangeCount;
@property (nonatomic, assign) BOOL ignoreNextPasteboardChangeLocal;
@property (nonatomic, copy)   NSString *pasteboardActionText;
@property (nonatomic, assign) BOOL observingPasteboardChanges;
@property (nonatomic, assign) BOOL observingLayoutChanges;
@property (nonatomic, assign) CGFloat autoScrollVelocity;
@property (nonatomic, assign) CGPoint autoScrollPanPoint;
@property (nonatomic, strong) CADisplayLink *autoScrollDisplayLink;
@end

@implementation SXPasteboardActionButton

+ (instancetype)shared {
    static SXPasteboardActionButton *s; static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [[SXPasteboardActionButton alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    });
    return s;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // ⚠️ 这里绝不可建 UIButton / 读 UIPasteboard：
        // 本类可能在 dyld 构造阶段被实例化，那时 UIKit 还没起来。
        self.hidden = YES;
    }
    return self;
}

/// 视图懒建：只有真要显示浮钮时才碰 UIKit
- (void)sx_buildSubviewsIfNeeded {
    if (self.button) return;

    self.backgroundColor = UIColor.clearColor;
    self.button = [UIButton buttonWithType:UIButtonTypeSystem];
    self.button.frame = self.bounds;
    [self.button setImage:[UIImage systemImageNamed:@"doc.on.doc"] forState:UIControlStateNormal];
    self.button.tintColor = UIColor.whiteColor;
    [self.button addTarget:self action:@selector(handlePasteboardActionButtonTap)
          forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.button];

    self.gradient = [CAGradientLayer layer];
    self.gradient.frame = self.bounds;
    self.gradient.cornerRadius = 22;
    [self.layer insertSublayer:self.gradient atIndex:0];
    [self updatePasteboardActionButtonGradient];

    self.layer.shadowColor = UIColor.blackColor.CGColor;
    self.layer.shadowOpacity = 0.25;
    self.layer.shadowRadius = 8;
    self.layer.shadowOffset = CGSizeMake(0, 3);

    _pasteboardButtonPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(handlePasteboardActionButtonPan:)];
    [self addGestureRecognizer:_pasteboardButtonPanGesture];
    _pasteboardButtonLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(handlePasteboardActionButtonLongPress:)];
    [self addGestureRecognizer:_pasteboardButtonLongPress];
    _pasteboardEdgePanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                        action:@selector(handlePasteboardActionButtonEdgePan:)];
    [self addGestureRecognizer:_pasteboardEdgePanGesture];
}

#pragma mark - 剪贴板监听

- (void)startObservingPasteboardChanges {
    if (self.observingPasteboardChanges) return;
    self.observingPasteboardChanges = YES;
    self.lastPasteboardChangeCount = -1;   // 首次收到变更时再建立基线
    [[NSNotificationCenter defaultCenter] addObserver:self
        selector:@selector(handlePasteboardChanged)
        name:UIPasteboardChangedNotification object:nil];
}

- (void)stopObservingPasteboardChanges {
    self.observingPasteboardChanges = NO;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIPasteboardChangedNotification object:nil];
}

- (void)handlePasteboardChanged {
    UIPasteboard *pb = UIPasteboard.generalPasteboard;
    NSInteger cc = pb.changeCount;
    if (self.lastPasteboardChangeCount < 0) { self.lastPasteboardChangeCount = cc; return; }
    if (cc == self.lastPasteboardChangeCount) return;
    self.lastPasteboardChangeCount = cc;
    if (self.ignoreNextPasteboardChangeLocal) { self.ignoreNextPasteboardChangeLocal = NO; return; }
    NSString *s = pb.string;
    if (s.length) [self showPasteboardActionButtonWithText:s];
}

#pragma mark - 显示

- (void)showPasteboardActionButtonWithText:(NSString *)text {
    self.pasteboardActionText = text;
    if (![[SXConfig shared] boolForKey:@"wantsPasteboardButton" default:YES]) return;
    [self sx_buildSubviewsIfNeeded];
    self.hidden = NO;
    self.alpha = 0;
    [UIView animateWithDuration:0.18 animations:^{ self.alpha = 1; }];
    [self restartPasteboardActionTimer];
}

- (void)hidePasteboardActionButton {
    [UIView animateWithDuration:0.18 animations:^{ self.alpha = 0; }
                     completion:^(BOOL f) { self.hidden = YES; }];
    [self.pasteboardActionTimer invalidate]; self.pasteboardActionTimer = nil;
}

- (void)restartPasteboardActionTimer {
    [self.pasteboardActionTimer invalidate];
    self.pasteboardActionTimer = [NSTimer scheduledTimerWithTimeInterval:6.0 repeats:NO
                                                                  block:^(NSTimer *t) {
        [self hidePasteboardActionButton];
    }];
}

- (void)updatePasteboardActionButtonGradient {
    NSInteger idx = [[SXConfig shared] integerForKey:@"buttonColorIndex" default:0];
    NSArray<NSArray<UIColor *> *> *palette = @[
        @[[UIColor colorWithRed:0.29 green:0.56 blue:1.0 alpha:1], [UIColor colorWithRed:0.51 green:0.34 blue:0.98 alpha:1]],
        @[[UIColor colorWithRed:1.0 green:0.42 blue:0.42 alpha:1], [UIColor colorWithRed:0.98 green:0.27 blue:0.62 alpha:1]],
        @[[UIColor colorWithRed:0.20 green:0.78 blue:0.55 alpha:1], [UIColor colorWithRed:0.13 green:0.62 blue:0.72 alpha:1]],
        @[[UIColor colorWithRed:0.98 green:0.66 blue:0.20 alpha:1], [UIColor colorWithRed:0.94 green:0.42 blue:0.16 alpha:1]],
        @[[UIColor colorWithRed:0.55 green:0.55 blue:0.60 alpha:1], [UIColor colorWithRed:0.30 green:0.30 blue:0.35 alpha:1]],
    ];
    NSArray<UIColor *> *pair = palette[idx % palette.count];
    self.gradient.colors = @[(id)pair[0].CGColor, (id)pair[1].CGColor];
    self.gradient.startPoint = CGPointMake(0, 0);
    self.gradient.endPoint = CGPointMake(1, 1);
}

#pragma mark - 交互

- (void)handlePasteboardActionButtonTap {
    self.pasteboardActionCancelledBySlide = NO;
    if (self.actionHandler) self.actionHandler(self.pasteboardActionText ?: @"");
}

- (void)handlePasteboardActionButtonLongPress:(UILongPressGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan) [self _enterPasteboardButtonEditMode];
}

- (void)_enterPasteboardButtonEditMode {
    self.pasteboardButtonEditingMode = YES;
    [UIView animateWithDuration:0.12 animations:^{
        self.transform = CGAffineTransformMakeScale(1.12, 1.12);
    } completion:^(BOOL f) {
        [UIView animateWithDuration:0.12 animations:^{ self.transform = CGAffineTransformIdentity; }];
    }];
}

- (void)handlePasteboardActionButtonPan:(UIPanGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.center.x + [g translationInView:self.superview].x,
                                  self.center.y + [g translationInView:self.superview].y);
        [g setTranslation:CGPointZero inView:self.superview];
        self.pasteboardActionCancelledBySlide = YES;
    } else if (g.state == UIGestureRecognizerStateEnded) {
        // 吸附到左右边缘
        CGFloat w = CGRectGetWidth(self.superview.bounds);
        CGFloat x = (self.center.x < w / 2) ? 30 : w - 30;
        [UIView animateWithDuration:0.2 animations:^{ self.center = CGPointMake(x, self.center.y); }];
        [self restartPasteboardActionTimer];
    }
}

- (void)handlePasteboardActionButtonEdgePan:(UIPanGestureRecognizer *)g {
    [self handlePasteboardActionButtonPan:g];
}

- (void)showPasteboardActionButtonMenu { self.pasteboardMenuVisible = YES; }

- (void)applyAutoScrollForPanPoint:(CGPoint)p { self.autoScrollPanPoint = p; }
- (void)handleAutoScroll { }
- (void)startAutoScroll { }
- (void)stopAutoScroll { }

@end
