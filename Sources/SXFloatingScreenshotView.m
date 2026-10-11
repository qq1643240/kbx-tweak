#import "SXFloatingScreenshotView.h"
#import "SXConstants.h"

@interface SXFloatingScreenshotView ()
@property (nonatomic, weak) UIView *hostView;
@property (nonatomic, assign) BOOL screenshotWindowLevelActive;
@property (nonatomic, assign) CGFloat screenshotPreviousWindowLevel;
@property (nonatomic, assign) CGPoint beganAt;
@property (nonatomic, assign) BOOL interacting;
@end

@implementation SXFloatingScreenshotView

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame hostView:(UIView *)host {
    if ((self = [super initWithImage:image])) {
        _hostView = host;
        self.frame = frame;
        self.userInteractionEnabled = YES;
        self.contentMode = UIViewContentModeScaleAspectFit;
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
        self.layer.borderWidth = 1.0;
        self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
        self.layer.shadowColor = UIColor.blackColor.CGColor;
        self.layer.shadowOpacity = 0.35;
        self.layer.shadowRadius = 12;
        self.layer.shadowOffset = CGSizeMake(0, 6);

        UITapGestureRecognizer *dbl = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleDoubleTap:)];
        dbl.numberOfTapsRequired = 2;
        [self addGestureRecognizer:dbl];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(moveWithPan:)];
        [self addGestureRecognizer:pan];

        UILongPressGestureRecognizer *lp = [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(handleLongPressGesture:)];
        [self addGestureRecognizer:lp];
    }
    return self;
}

- (void)showFloatingImage:(UIImage *)image frame:(CGRect)frame hostView:(UIView *)host
                     menu:(UIMenu *)menu dismissalHandler:(void (^)(void))handler {
    self.image = image;
    self.frame = frame;
    self.hostView = host;
    self.dismissalHandler = handler;
    [host addSubview:self];
    self.alpha = 0;
    self.transform = CGAffineTransformMakeScale(0.8, 0.8);
    [UIView animateWithDuration:0.28 delay:0 usingSpringWithDamping:0.78 initialSpringVelocity:0.4
                        options:0 animations:^{
        self.alpha = 1; self.transform = CGAffineTransformIdentity;
    } completion:nil];
    if (menu) {
        UIContextMenuInteraction *ci = [[UIContextMenuInteraction alloc] initWithDelegate:(id)self];
        [self addInteraction:ci];
    }
}

#pragma mark - 拖动

- (void)moveWithPan:(UIPanGestureRecognizer *)g {
    CGPoint t = [g translationInView:self.superview];
    if (g.state == UIGestureRecognizerStateBegan) {
        self.interacting = YES;
        if (self.interactionChangedHandler) self.interactionChangedHandler(YES);
    } else if (g.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.center.x + t.x, self.center.y + t.y);
        [g setTranslation:CGPointZero inView:self.superview];
    } else {
        self.interacting = NO;
        if (self.interactionChangedHandler) self.interactionChangedHandler(NO);
        [self snapToNearestEdge];
    }
}

- (void)snapToNearestEdge {
    UIView *host = self.superview; if (!host) return;
    CGFloat w = CGRectGetWidth(host.bounds), h = CGRectGetHeight(host.bounds);
    CGFloat x = CGRectGetMidX(self.frame) < w / 2 ? 16 : w - CGRectGetWidth(self.frame) - 16;
    CGFloat y = MIN(MAX(16, CGRectGetMinY(self.frame)), h - CGRectGetHeight(self.frame) - 16);
    [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:0.85 initialSpringVelocity:0.3
                        options:0 animations:^{
        self.frame = CGRectMake(x, y, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    } completion:nil];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)g {
    [self removeImmediately];
    if (self.dismissalHandler) self.dismissalHandler();
}

- (void)handleScreenshotDoubleTap:(UITapGestureRecognizer *)g { [self handleDoubleTap:g]; }

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)g {
    if (g.state == UIGestureRecognizerStateBegan && self.dismissalHandler) self.dismissalHandler();
}

- (void)removeImmediately {
    [UIView animateWithDuration:0.16 animations:^{
        self.alpha = 0; self.transform = CGAffineTransformMakeScale(0.85, 0.85);
    } completion:^(BOOL f) { [self removeFromSuperview]; }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.beganAt = [touches.anyObject locationInView:self.superview];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint p = [touches.anyObject locationInView:self.superview];
    self.center = CGPointMake(self.center.x + (p.x - self.beganAt.x),
                              self.center.y + (p.y - self.beganAt.y));
    self.beganAt = p;
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self snapToNearestEdge];
    [super touchesEnded:touches withEvent:event];
}

#pragma mark - 窗口层级

- (void)beginScreenshotWindowLevel {
    self.screenshotWindowLevelActive = YES;
    UIWindow *win = self.window;
    self.screenshotPreviousWindowLevel = win.windowLevel;
    win.windowLevel = UIWindowLevelAlert + 1;
}

- (void)endScreenshotWindowLevel {
    if (!self.screenshotWindowLevelActive) return;
    self.window.windowLevel = self.screenshotPreviousWindowLevel;
    self.screenshotWindowLevelActive = NO;
}

@end
