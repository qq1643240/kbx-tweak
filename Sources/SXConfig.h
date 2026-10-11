//
//  SXConfig.h
//  偏好读写。复刻版：不含任何授权键。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXConfig : NSObject

+ (instancetype)shared;

/// 当前生效的偏好字典（内存缓存 + 落盘）
@property (nonatomic, readonly) NSMutableDictionary *prefs;

- (nullable id)objectForKey:(NSString *)key;
- (void)setObject:(nullable id)value forKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key default:(BOOL)def;
- (NSInteger)integerForKey:(NSString *)key default:(NSInteger)def;
- (nullable NSString *)stringForKey:(NSString *)key;

/// 落盘到 /var/mobile/Library/Preferences/com.superx.plist
- (void)synchronize;

/// 恢复默认（保留用户自定义人设以外的键）
- (void)resetPreferenceKeys;

/// 重载（收到 darwin 通知时调用）
- (void)reload;

@end

NS_ASSUME_NONNULL_END
