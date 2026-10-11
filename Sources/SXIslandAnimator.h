//
//  SXIslandAnimator.h
//  灵动岛 reveal / 呼吸 / 收缩 动画（原版 SXIslandAnimator + SuperXAnimation.*）
//
//  说明：原版含 SpriteKit + Metal shader 的「水滴折射」涟漪。此处用
//  Core Animation 复刻同一时间线（onset 0.065 / decay 平方衰减 / 前沿扩散），
// 视觉近似而非像素级一致。
//

#import <UIKit/UIKit.h>
@class SXPopupView;

NS_ASSUME_NONNULL_BEGIN

@interface SXIslandAnimator : NSObject
+ (instancetype)shared;

@property (nonatomic, assign) NSTimeInterval duration;      // 默认 0.62
@property (nonatomic, assign) CGFloat impactPointScale;     // 默认 1.0
@property (nonatomic, assign) BOOL preservePopup;           // 默认 YES

/// 岛 → 目标视图 的揭示动画
- (void)animateFromIslandToView:(UIView *)target
                      overlay:(UIView *)overlay
                   glowLayers:(NSArray<CALayer *> *)glowLayers
                   islandRect:(CGRect)islandRect
           islandCornerRadius:(CGFloat)radius
                   travelPaths:(NSArray<NSValue *> *)paths
                 travelCenters:(NSArray<NSValue *> *)centers
                revealStarted:(nullable void (^)(void))started
                     completion:(nullable void (^)(void))done;

/// 呼吸（静止态）
- (void)startBreathOnView:(UIView *)view;
- (void)stopBreathOnView:(UIView *)view;

/// 收缩回岛
- (void)contractToView:(UIView *)view completion:(nullable void (^)(void))done;

/// 取消
- (void)cancelPopupReveal;

@end

NS_ASSUME_NONNULL_END
