//
//  SXFloatingScreenshotView.h
//  截图的悬浮小窗（原版 C_KbAiFloatingScreenshotView / HACFVF / IYKJLM / JYFOAZ 的集合）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXFloatingScreenshotView : UIImageView

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIView *borderTargetView;
@property (nonatomic, strong) NSArray<UIView *> *glowLayers;
@property (nonatomic, assign) CGFloat maskRadius;
@property (nonatomic, assign) CGSize  maskSize;
@property (nonatomic, assign) CGFloat borderCornerRadius;

@property (nonatomic, copy, nullable) void (^dismissalHandler)(void);
@property (nonatomic, copy, nullable) void (^interactionChangedHandler)(BOOL interacting);

- (instancetype)initWithImage:(UIImage *)image frame:(CGRect)frame hostView:(UIView *)host;
- (void)showFloatingImage:(UIImage *)image frame:(CGRect)frame
                 hostView:(UIView *)host menu:(nullable UIMenu *)menu
         dismissalHandler:(nullable void (^)(void))handler;

- (void)moveWithPan:(UIPanGestureRecognizer *)g;
- (void)handleDoubleTap:(UITapGestureRecognizer *)g;
- (void)handleScreenshotDoubleTap:(UITapGestureRecognizer *)g;
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;
- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(nullable UIEvent *)event;

/// 截图窗口层级提升（原版 screenshotWindowLevelActive 语义）
- (void)beginScreenshotWindowLevel;
- (void)endScreenshotWindowLevel;

@end

NS_ASSUME_NONNULL_END
