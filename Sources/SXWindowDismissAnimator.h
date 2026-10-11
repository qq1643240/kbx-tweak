//
//  SXWindowDismissAnimator.h
//  弹窗收起动画（原版 SXWindowDismissAnimator，含「保留到下次到达」语义）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXWindowDismissAnimator : NSObject
+ (instancetype)shared;

@property (nonatomic, assign) BOOL preservePopupForNextArrival;
@property (nonatomic, assign) BOOL closingRemote;

/// 收起：可选先收缩回灵动岛
- (void)dismissPopup:(UIView *)popup completion:(nullable void (^)(void))done;
- (void)animatePopupDismissalForView:(UIView *)popup completion:(nullable void (^)(void))done;
- (void)animatePopupPresentationForView:(UIView *)popup hostView:(UIView *)host
                            targetFrame:(CGRect)frame usesPseudoLandscapeLayout:(BOOL)pseudo;
- (void)applyPopupTransformForHostView:(UIView *)host toPopupView:(UIView *)popup scale:(CGFloat)scale;

@end

NS_ASSUME_NONNULL_END
