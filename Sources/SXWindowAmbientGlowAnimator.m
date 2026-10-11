#import "SXWindowAmbientGlowAnimator.h"
#import "SXIslandGeometry.h"

@implementation SXWindowAmbientGlowAnimator

+ (instancetype)shared {
    static SXWindowAmbientGlowAnimator *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXWindowAmbientGlowAnimator new]; });
    return s;
}

- (NSArray<CALayer *> *)installGlowLayers:(NSArray<CALayer *> *)layers
                                   overlay:(UIView *)overlay popup:(UIView *)popup {
    NSMutableArray<CALayer *> *made = [NSMutableArray array];
    SXIslandGeometry *g = [SXIslandGeometry shared];
    for (int i = 0; i < 2; i++) {
        CAGradientLayer *l = [CAGradientLayer layer];
        l.type = kCAGradientLayerRadial;
        l.colors = @[(id)[UIColor colorWithWhite:1.0 alpha:0.16 - i * 0.06].CGColor,
                     (id)[UIColor colorWithWhite:1.0 alpha:0.0].CGColor];
        l.startPoint = CGPointMake(0.5, 0.5);
        l.endPoint = CGPointMake(1.0, 1.0);
        l.shadowRadius = g.shadowRadius;
        [overlay.layer insertSublayer:l atIndex:0];
        [made addObject:l];
    }
    self.glowLayers = made;
    self.ambientGlowInstalled = YES;
    return made;
}

- (void)updateGlowLayers:(NSArray<CALayer *> *)layers overlay:(UIView *)overlay popup:(UIView *)popup {
    CGRect f = popup ? CGRectInset(popup.frame, -24, -24) : overlay.bounds;
    for (CALayer *l in layers ?: self.glowLayers) l.frame = f;
}

- (void)showAmbientGlowForPopup:(UIView *)popup {
    self.ambientGlowActive = YES;
    [self updateGlowLayers:self.glowLayers overlay:popup.superview popup:popup];
    for (CALayer *l in self.glowLayers) {
        CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"opacity"];
        a.fromValue = @0; a.toValue = @1; a.duration = 0.32;
        [l addAnimation:a forKey:@"sx.glow"];
    }
}

- (void)fadeOutActiveGlow {
    self.ambientGlowActive = NO;
    for (CALayer *l in self.glowLayers) {
        CABasicAnimation *a = [CABasicAnimation animationWithKeyPath:@"opacity"];
        a.fromValue = @1; a.toValue = @0; a.duration = 0.24;
        a.fillMode = kCAFillModeForwards; a.removedOnCompletion = NO;
        [l addAnimation:a forKey:@"sx.glow.out"];
    }
}

- (void)applyWindowGlowStyle {
    SXIslandGeometry *g = [SXIslandGeometry shared];
    for (CALayer *l in self.glowLayers) l.shadowRadius = g.shadowRadius;
}

@end
