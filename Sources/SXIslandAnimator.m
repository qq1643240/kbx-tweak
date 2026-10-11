#import "SXIslandAnimator.h"
#import "SXPopupView.h"

@implementation SXIslandAnimator

+ (instancetype)shared {
    static SXIslandAnimator *s; static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [SXIslandAnimator new];
        s.duration = 0.62; s.impactPointScale = 1.0; s.preservePopup = YES;
    });
    return s;
}

- (void)animateFromIslandToView:(UIView *)target overlay:(UIView *)overlay
                     glowLayers:(NSArray<CALayer *> *)glowLayers
                     islandRect:(CGRect)islandRect islandCornerRadius:(CGFloat)radius
                     travelPaths:(NSArray<NSValue *> *)paths travelCenters:(NSArray<NSValue *> *)centers
                  revealStarted:(void (^)(void))started completion:(void (^)(void))done {

    if (started) started();

    // 1) 岛上的「冲击点」高光
    UIView *impact = [[UIView alloc] initWithFrame:islandRect];
    impact.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.28];
    impact.layer.cornerRadius = radius;
    impact.userInteractionEnabled = NO;
    [overlay addSubview:impact];

    // 2) 前沿扩散环（对应 shader 里的 front = t*maxDist - 18）
    CAShapeLayer *front = [CAShapeLayer layer];
    front.fillColor = UIColor.clearColor.CGColor;
    front.strokeColor = [UIColor colorWithWhite:1.0 alpha:0.55].CGColor;
    front.lineWidth = 2.0;
    front.path = [UIBezierPath bezierPathWithRoundedRect:islandRect cornerRadius:radius].CGPath;
    [overlay.layer addSublayer:front];

    // 3) 光晕
    for (CALayer *g in glowLayers) {
        g.opacity = 0;
        [overlay.layer addSublayer:g];
    }

    CGFloat total = self.duration;
    // onset = smoothstep(0, 0.065, t) → 起始延迟
    CGFloat onset = 0.065 * total;

    [UIView animateWithDuration:onset animations:^{
        impact.transform = CGAffineTransformMakeScale(1.12 * self.impactPointScale,
                                                      1.12 * self.impactPointScale);
        impact.alpha = 0.9;
    }];

    // 前沿扩散
    CABasicAnimation *grow = [CABasicAnimation animationWithKeyPath:@"path"];
    CGRect endRect = target ? target.frame : islandRect;
    grow.fromValue = (id)front.path;
    grow.toValue = (id)[UIBezierPath bezierPathWithRoundedRect:endRect cornerRadius:radius].CGPath;
    grow.duration = total - onset;
    grow.beginTime = CACurrentMediaTime() + onset;
    grow.fillMode = kCAFillModeForwards;
    grow.removedOnCompletion = NO;
    grow.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [front addAnimation:grow forKey:@"front"];

    // decay = (1-t)^2 → 环渐隐
    CABasicAnimation *fade = [CABasicAnimation animationWithKeyPath:@"opacity"];
    fade.fromValue = @0.55; fade.toValue = @0.0;
    fade.duration = total - onset; fade.beginTime = CACurrentMediaTime() + onset;
    fade.fillMode = kCAFillModeForwards; fade.removedOnCompletion = NO;
    [front addAnimation:fade forKey:@"fade"];

    // 4) 目标视图揭示
    target.alpha = 0;
    target.transform = CGAffineTransformMakeScale(0.94, 0.94);
    [UIView animateWithDuration:total - onset delay:onset
         usingSpringWithDamping:0.82 initialSpringVelocity:0.35
                        options:UIViewAnimationOptionCurveEaseOut animations:^{
        target.alpha = 1; target.transform = CGAffineTransformIdentity;
        for (CALayer *g in glowLayers) g.opacity = 1;
    } completion:^(BOOL f) {
        [impact removeFromSuperview];
        [front removeFromSuperlayer];
        if (done) done();
    }];
}

- (void)startBreathOnView:(UIView *)view {
    CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    a.fromValue = @1.0; a.toValue = @1.015;
    a.duration = 1.8; a.autoreverses = YES; a.repeatCount = HUGE_VALF;
    a.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    [view.layer addAnimation:a forKey:@"sx.breath"];
}

- (void)stopBreathOnView:(UIView *)view { [view.layer removeAnimationForKey:@"sx.breath"]; }

- (void)contractToView:(UIView *)view completion:(void (^)(void))done {
    [UIView animateWithDuration:0.24 delay:0 usingSpringWithDamping:0.9 initialSpringVelocity:0.3
                        options:UIViewAnimationOptionCurveEaseIn animations:^{
        view.transform = CGAffineTransformMakeScale(0.9, 0.9);
        view.alpha = 0;
    } completion:^(BOOL f) { if (done) done(); }];
}

- (void)cancelPopupReveal { }

@end
