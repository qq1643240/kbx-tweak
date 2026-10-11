#import "SXIntelligenceLoadingView.h"
#import "SXIslandGeometry.h"

@interface SXIntelligenceLoadingView ()
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIView *dotsView;
@property (nonatomic, strong) NSTimer *motionTimer;
@property (nonatomic, assign) CGFloat phase;
@end

@implementation SXIntelligenceLoadingView

- (instancetype)initWithSize:(CGSize)size {
    if ((self = [super initWithFrame:CGRectMake(0, 0, size.width, size.height)])) {
        UIBlurEffect *e = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
        _blurEffectView = [[UIVisualEffectView alloc] initWithEffect:e];
        _blurEffectView.frame = self.bounds;
        _blurEffectView.layer.cornerRadius = size.height / 2.0;
        _blurEffectView.layer.masksToBounds = YES;
        _blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_blurEffectView];

        _dotsView = [[UIView alloc] initWithFrame:self.bounds];
        _dotsView.userInteractionEnabled = NO;
        [self addSubview:_dotsView];
        for (int i = 0; i < 3; i++) {
            UIView *d = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
            d.backgroundColor = UIColor.whiteColor;
            d.layer.cornerRadius = 3;
            d.tag = 100 + i;
            [_dotsView addSubview:d];
        }
        self.layer.cornerRadius = size.height / 2.0;
        self.clipsToBounds = NO;
    }
    return self;
}

- (void)startAnimating {
    [self.motionTimer invalidate];
    self.motionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 repeats:YES block:^(NSTimer *t) {
        [self updateMotion];
    }];
}

- (void)stopAnimating {
    [self.motionTimer invalidate]; self.motionTimer = nil;
}

- (void)updateMotion {
    self.phase += 0.14;
    CGFloat w = CGRectGetWidth(self.bounds), h = CGRectGetHeight(self.bounds);
    CGFloat gap = 14.0;
    for (int i = 0; i < 3; i++) {
        UIView *d = [self viewWithTag:100 + i];
        CGFloat x = w / 2.0 + (i - 1) * gap;
        CGFloat s = 1.0 + 0.35 * sin(self.phase - i * 0.6);
        d.center = CGPointMake(x, h / 2.0);
        d.transform = CGAffineTransformMakeScale(s, s);
        d.alpha = 0.55 + 0.45 * (s - 0.65);
    }
    if (self.activeGlow || self.ambientGlowActive) [self updateIslandTracking];
}

- (void)updateIslandTracking {
    SXIslandGeometry *g = [SXIslandGeometry shared];
    if (CGRectIsEmpty(g.islandRect)) return;
    // 轻微跟随灵动岛中心
    CGFloat dx = (CGRectGetMidX(g.islandRect) - CGRectGetMidX(self.frame)) * 0.02;
    self.transform = CGAffineTransformMakeTranslation(dx, 0);
}

- (void)fadeOutActiveGlow {
    self.activeGlow = NO;
    [UIView animateWithDuration:0.24 animations:^{ self.alpha = 0; }];
}

@end
