//
//  SXWindowAmbientGlowAnimator.h
//  窗口环境光晕（原版 SXWindowAmbientGlowAnimator，键 island.shadowRadius / island.lineWidth）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXWindowAmbientGlowAnimator : NSObject
+ (instancetype)shared;

@property (nonatomic, assign) BOOL ambientGlowActive;
@property (nonatomic, assign) BOOL ambientGlowInstalled;
@property (nonatomic, strong, nullable) NSArray<CALayer *> *glowLayers;

/// 安装光晕层到 overlay
- (NSArray<CALayer *> *)installGlowLayers:(NSArray<CALayer *> *)layers
                                  overlay:(UIView *)overlay
                                    popup:(UIView *)popup;

- (void)updateGlowLayers:(NSArray<CALayer *> *)layers overlay:(UIView *)overlay popup:(UIView *)popup;
- (void)showAmbientGlowForPopup:(UIView *)popup;
- (void)fadeOutActiveGlow;
- (void)applyWindowGlowStyle;

@end

NS_ASSUME_NONNULL_END
