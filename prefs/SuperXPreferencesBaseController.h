//
//  SuperXPreferencesBaseController.h
//  设置面板基类。
//
//  复刻说明：原版此基类含 isLicenseActivated / getActivationStateText，
//  是两处授权判定之一。复刻版**已整体删除**授权相关成员，
//  SXIsActivated() 恒为 YES（见 Sources/SXConstants.h）。
//

#import <Preferences/Preferences.h>
#import <Preferences/PSSpecifier.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuperXPreferencesBaseController : PSListController

/// 偏好读写
- (NSMutableDictionary *)mutablePreferencesDictionary;
- (NSDictionary *)preferencesDictionary;
- (NSString *)preferencesPath;
- (void)writePreferencesDictionary:(NSDictionary *)dict;
- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier;
- (id)readPreferenceValue:(PSSpecifier *)specifier;

/// 重置（保留自定义人设）
- (void)resetPreferenceKeys;
- (void)performReset;
- (void)performResetOrder;
- (void)resetOrder;
- (void)reloadButtonOrder;
- (void)saveOrder;

/// 跳转 Snapper3 安装页
- (void)goToSileoMarkTweak;

/// 双语文案
- (NSString *)localizedTextZh:(NSString *)zh en:(NSString *)en;

/// 复用型 specifier 构造
- (PSSpecifier *)createGroupCellWithLabel:(NSString *)label footerText:(nullable NSString *)footer;
- (PSSpecifier *)createGroupCellWithLabel:(NSString *)label footerText:(nullable NSString *)footer
                             centerFooter:(BOOL)center;
- (PSSpecifier *)createListCellWithNamed:(NSString *)name key:(NSString *)key
                                  titles:(NSArray *)titles values:(NSArray *)values
                                  iconSF:(nullable NSString *)sf;
- (PSSpecifier *)createListCellWithNamed:(NSString *)name key:(NSString *)key
                                  titles:(NSArray *)titles values:(NSArray *)values
                                  iconSF:(nullable NSString *)sf default:(NSInteger)def;
- (PSSpecifier *)createActionCellWithLabel:(NSString *)label action:(SEL)action
                                    iconSF:(nullable NSString *)sf;
- (PSSpecifier *)subtitleSwitchSpecifierWithName:(NSString *)name subtitle:(nullable NSString *)sub
                                             key:(NSString *)key defaultValue:(BOOL)def
                                          iconSF:(nullable NSString *)sf;
- (PSSpecifier *)subtitleButtonSpecifierWithName:(NSString *)name subtitle:(nullable NSString *)sub
                                          action:(SEL)action iconSF:(nullable NSString *)sf;
- (PSSpecifier *)subtitleLinkSpecifierWithName:(NSString *)name subtitle:(nullable NSString *)sub
                                        detail:(NSString *)detail iconSF:(nullable NSString *)sf;

/// 工具
- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)r;
- (UIColor *)interpolateColorFrom:(UIColor *)a to:(UIColor *)b ratio:(CGFloat)t;
- (UIColor *)colorMakeVivid:(UIColor *)c sat:(CGFloat)sat bright:(CGFloat)b;
- (void)applySFIconsToSpecifiers:(NSArray<PSSpecifier *> *)specs;
- (void)openColorPicker:(id)sender defaultColor:(UIColor *)color;
- (void)saveSelectedColor:(UIColor *)color toKey:(NSString *)key;
- (NSArray *)parseModels:(id)raw;
- (NSArray *)parseCustomOptions:(id)raw;
- (NSArray *)parseCustomOptionEntries:(id)raw;
- (NSArray *)searchEnginesFromConfig;
- (void)presentSafariWithURLString:(NSString *)url;
- (void)tipsAlertToRespring;

@end

NS_ASSUME_NONNULL_END
