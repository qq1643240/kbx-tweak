//
//  SXIslandGeometry.h
//  灵动岛几何：屏幕安全区 → 岛位置/尺寸/圆角
//  原版键：island.position / island.bounds / island.cornerRadius
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXIslandGeometry : NSObject
+ (instancetype)shared;

@property (nonatomic, assign) CGRect  islandRect;
@property (nonatomic, assign) CGFloat islandCornerRadius;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat shadowRadius;

/// 依据宿主视图与状态栏高度刷新岛几何
- (void)updateWithHostView:(UIView *)host statusBarTop:(CGFloat)statusTop;

/// 从岛到目标视图的飞行路径（用于 reveal 动画）
- (NSArray<NSValue *> *)travelPathsFromIslandToView:(UIView *)target;
- (NSArray<NSValue *> *)travelCentersFromIslandToView:(UIView *)target;

@end

NS_ASSUME_NONNULL_END
