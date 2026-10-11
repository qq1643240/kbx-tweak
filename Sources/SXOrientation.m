#import "SXOrientation.h"

@implementation SXOrientation

+ (instancetype)shared {
    static SXOrientation *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXOrientation new]; });
    return s;
}

- (UIWindow *)keyWindow {
    for (UIScene *sc in UIApplication.sharedApplication.connectedScenes) {
        if (![sc isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *w in ((UIWindowScene *)sc).windows) if (w.isKeyWindow) return w;
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

- (UIInterfaceOrientation)deviceOrientationForWindow:(UIWindow *)window {
    UIWindow *w = window ?: [self keyWindow];
    if (@available(iOS 13.0, *)) {
        UIInterfaceOrientation o = w.windowScene.interfaceOrientation;
        if (o != UIInterfaceOrientationUnknown) return o;
    }
    return UIInterfaceOrientationPortrait;
}

- (UIInterfaceOrientation)interfaceOrientationForWindow:(UIWindow *)window {
    return [self deviceOrientationForWindow:window];
}

- (UIInterfaceOrientation)deviceOrientation { return [self deviceOrientationForWindow:nil]; }

- (BOOL)isLandscapeForView:(UIView *)view {
    if (!view) return NO;
    return CGRectGetWidth(view.bounds) > CGRectGetHeight(view.bounds);
}

- (BOOL)isLandscapeForWindow:(UIWindow *)window {
    UIWindow *w = window ?: [self keyWindow];
    return [self isLandscapeForView:w];
}

- (BOOL)isForegroundApplicationLandscape {
    UIInterfaceOrientation o = [self deviceOrientation];
    return UIInterfaceOrientationIsLandscape(o);
}

- (UIImage *)rotateImageToPortrait:(UIImage *)image {
    if (!image) return nil;
    if (![self isForegroundApplicationLandscape]) return image;
    CGSize sz = CGSizeMake(image.size.height, image.size.width);
    UIGraphicsBeginImageContextWithOptions(sz, NO, image.scale);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, sz.width / 2, sz.height / 2);
    CGContextRotateCTM(ctx, M_PI_2);
    [image drawInRect:CGRectMake(-image.size.width / 2, -image.size.height / 2,
                                 image.size.width, image.size.height)];
    UIImage *out = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return out ?: image;
}

@end
