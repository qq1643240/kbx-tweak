//
//  SXIntelligenceLoadingView.h
//  等待 AI 返回时的加载指示（原版 C_SXIntelligenceLoadingView）
//  含呼吸光晕 + 跟随灵动岛的飞行效果。
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXIntelligenceLoadingView : UIView

@property (nonatomic, assign) BOOL activeGlow;
@property (nonatomic, assign) BOOL ambientGlowActive;
@property (nonatomic, assign) BOOL ambientGlowInstalled;
@property (nonatomic, strong) UIView *interactiveSubview;

- (instancetype)initWithSize:(CGSize)size;
- (void)startAnimating;
- (void)stopAnimating;
- (void)fadeOutActiveGlow;
- (void)updateMotion;
- (void)updateIslandTracking;

@end

NS_ASSUME_NONNULL_END
