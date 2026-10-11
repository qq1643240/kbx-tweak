#import "SXWindowDismissAnimator.h"

@implementation SXWindowDismissAnimator

+ (instancetype)shared {
    static SXWindowDismissAnimator *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXWindowDismissAnimator new]; s.preservePopupForNextArrival = YES; });
    return s;
}

- (void)dismissPopup:(UIView *)popup completion:(void (^)(void))done {
    if (self.preservePopupForNextArrival) {
        // 保留实例，仅隐藏（下次到达可直接复用，避免重建开销）
        [UIView animateWithDuration:0.2 animations:^{ popup.alpha = 0; }
                         completion:^(BOOL f) {
            popup.hidden = YES;
            if (done) done();
        }];
    } else {
        [self animatePopupDismissalForView:popup completion:done];
    }
}

- (void)animatePopupDismissalForView:(UIView *)popup completion:(void (^)(void))done {
    [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        popup.alpha = 0;
        popup.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL f) {
        [popup removeFromSuperview];
        popup.transform = CGAffineTransformIdentity;
        if (done) done();
    }];
}

- (void)animatePopupPresentationForView:(UIView *)popup hostView:(UIView *)host
                            targetFrame:(CGRect)frame usesPseudoLandscapeLayout:(BOOL)pseudo {
    popup.frame = frame;
    popup.alpha = 0;
    popup.transform = CGAffineTransformMakeScale(0.92, 0.92);
    [UIView animateWithDuration:0.26 delay:0 usingSpringWithDamping:0.82
         initialSpringVelocity:0.35 options:UIViewAnimationOptionCurveEaseOut animations:^{
        popup.alpha = 1;
        popup.transform = CGAffineTransformIdentity;
    } completion:nil];
}

- (void)applyPopupTransformForHostView:(UIView *)host toPopupView:(UIView *)popup scale:(CGFloat)scale {
    popup.transform = CGAffineTransformMakeScale(scale, scale);
}

@end
