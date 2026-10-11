#import "SXIslandGeometry.h"
#import "SXConfig.h"
#import "SXConstants.h"

@implementation SXIslandGeometry

+ (instancetype)shared {
    static SXIslandGeometry *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXIslandGeometry new]; s.lineWidth = 1.0; s.shadowRadius = 18.0; });
    return s;
}

- (void)updateWithHostView:(UIView *)host statusBarTop:(CGFloat)statusTop {
    CGFloat w = CGRectGetWidth(host.bounds);
    CGFloat islandW = MIN(126.0, w * 0.32);
    CGFloat islandH = 37.0;
    self.islandRect = CGRectMake((w - islandW) / 2.0, MAX(statusTop - 4.0, 0), islandW, islandH);
    self.islandCornerRadius = islandH / 2.0;
}

- (NSArray<NSValue *> *)travelPathsFromIslandToView:(UIView *)target {
    if (!target) return @[];
    CGRect t = [target.superview convertRect:target.frame toView:target.window];
    CGRect island = self.islandRect;
    CGPoint from = CGPointMake(CGRectGetMidX(island), CGRectGetMaxY(island));
    CGPoint to   = CGPointMake(CGRectGetMidX(t), CGRectGetMidY(t));
    // 二次贝塞尔控制点：中点 + 轻微上抛，形成「水滴」轨迹
    CGPoint ctrl = CGPointMake((from.x + to.x) / 2.0, MIN(from.y, to.y) - 24.0);
    NSMutableArray<NSValue *> *path = [NSMutableArray array];
    const int steps = 24;
    for (int i = 0; i <= steps; i++) {
        CGFloat t0 = (CGFloat)i / steps, u = 1 - t0;
        CGPoint p = CGPointMake(u*u*from.x + 2*u*t0*ctrl.x + t0*t0*to.x,
                                u*u*from.y + 2*u*t0*ctrl.y + t0*t0*to.y);
        [path addObject:[NSValue valueWithCGPoint:p]];
    }
    return path;
}

- (NSArray<NSValue *> *)travelCentersFromIslandToView:(UIView *)target {
    NSArray<NSValue *> *path = [self travelPathsFromIslandToView:target];
    if (!path.count) return @[];
    NSMutableArray<NSValue *> *centers = [NSMutableArray array];
    for (NSUInteger i = 1; i < path.count; i += 3) [centers addObject:path[i]];
    return centers;
}

@end
