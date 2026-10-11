//
//  SuperXQuickStartManager.h
//  快速上手向导（原版 SuperXQuickStartManager / Action / Option）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SuperXQuickStartAction : NSObject
@property (nonatomic, copy) NSString *titleZh;
@property (nonatomic, copy) NSString *titleEn;
@property (nonatomic, assign) NSInteger style;
@property (nonatomic, copy, nullable) void (^handler)(void);
+ (instancetype)actionWithTitleZh:(NSString *)zh titleEn:(NSString *)en
                            style:(NSInteger)style handler:(nullable void (^)(void))handler;
@end

@interface SuperXQuickStartOption : NSObject
@property (nonatomic, copy) NSString *titleZh;
@property (nonatomic, copy) NSString *titleEn;
@property (nonatomic, copy) NSString *messageZh;
@property (nonatomic, copy) NSString *messageEn;
@property (nonatomic, copy) NSArray<SuperXQuickStartAction *> *actions;
+ (instancetype)optionWithTitleZh:(NSString *)zh titleEn:(NSString *)en
                        messageZh:(NSString *)mzh messageEn:(NSString *)men
                          actions:(NSArray<SuperXQuickStartAction *> *)actions;
@end

@interface SuperXQuickStartManager : NSObject
+ (instancetype)shared;

@property (nonatomic, copy) NSArray<SuperXQuickStartOption *> *quickStartOptions;

- (void)presentFromController:(UIViewController *)controller
                    isChinese:(BOOL)isChinese
                    plistPath:(NSString *)plistPath;
- (void)presentQuickStartOption:(SuperXQuickStartOption *)option
                  fromController:(UIViewController *)controller isChinese:(BOOL)isChinese;

/// 一键应用：写端点 / 路径 / 模型
- (void)applyQuickStartURL:(NSString *)url path:(NSString *)path
                     model:(NSString *)model pictureModel:(nullable NSString *)pictureModel;

- (nullable SuperXQuickStartOption *)quickStartOptionFromDictionary:(NSDictionary *)dict;
- (nullable SuperXQuickStartAction *)quickStartActionFromDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
