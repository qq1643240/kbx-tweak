//
//  SXOrientation.h
//  屏幕方向判定（原版 C_KbAiOrientation）
//  SpringBoard 内不能依赖 UIApplication.statusBarOrientation，需要自行从
//  UIWindowScene / 状态栏方向推导。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXOrientation : NSObject
+ (instancetype)shared;

@property (nonatomic, readonly) UIInterfaceOrientation deviceOrientation;

- (UIInterfaceOrientation)deviceOrientationForWindow:(nullable UIWindow *)window;
- (UIInterfaceOrientation)interfaceOrientationForWindow:(nullable UIWindow *)window;

- (BOOL)isLandscapeForView:(UIView *)view;
- (BOOL)isLandscapeForWindow:(nullable UIWindow *)window;
- (BOOL)isForegroundApplicationLandscape;

/// 把图片旋正为竖屏朝向
- (UIImage *)rotateImageToPortrait:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
