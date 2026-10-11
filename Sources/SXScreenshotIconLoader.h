//
//  SXScreenshotIconLoader.h
//  截图动作图标加载（原版 C_KbAiScreenshotIconLoader）
//  图标目录：/Library/PreferenceBundles/SuperXPrefs.bundle/actions
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXScreenshotIconLoader : NSObject
+ (instancetype)shared;

/// 取动作图标。name ∈ {1,2,3,4,copy,save,close,mark}
+ (nullable UIImage *)imageForAction:(NSString *)name;
+ (nullable UIImage *)imageForAction:(NSString *)name scale:(CGFloat)scale;

/// 面板里「动作」列表用的图标（默认回落到 SF Symbol）
+ (nullable UIImage *)iconTokenForPersona:(NSString *)persona fallbackIndex:(NSInteger)idx;

@end

NS_ASSUME_NONNULL_END
