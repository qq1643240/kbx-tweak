#import "SuperXQuickStartManager.h"
#import "SXConstants.h"

#pragma mark - Action

@implementation SuperXQuickStartAction
+ (instancetype)actionWithTitleZh:(NSString *)zh titleEn:(NSString *)en
                            style:(NSInteger)style handler:(void (^)(void))handler {
    SuperXQuickStartAction *a = [SuperXQuickStartAction new];
    a.titleZh = zh; a.titleEn = en; a.style = style; a.handler = handler;
    return a;
}
@end

#pragma mark - Option

@implementation SuperXQuickStartOption
+ (instancetype)optionWithTitleZh:(NSString *)zh titleEn:(NSString *)en
                        messageZh:(NSString *)mzh messageEn:(NSString *)men
                          actions:(NSArray<SuperXQuickStartAction *> *)actions {
    SuperXQuickStartOption *o = [SuperXQuickStartOption new];
    o.titleZh = zh; o.titleEn = en; o.messageZh = mzh; o.messageEn = men; o.actions = actions;
    return o;
}
@end

#pragma mark - Manager

@implementation SuperXQuickStartManager

+ (instancetype)shared {
    static SuperXQuickStartManager *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SuperXQuickStartManager new]; [s buildDefaultOptions]; });
    return s;
}

- (void)buildDefaultOptions {
    __weak typeof(self) ws = self;
    SuperXQuickStartOption *official = [SuperXQuickStartOption
        optionWithTitleZh:@"使用公共密钥" titleEn:@"Use the public key"
                messageZh:@"默认使用公共密钥，有每日额度限制。想要更好体验，请查看快速上手，申请个人密钥。"
                messageEn:@"The public key is used by default, with a daily limit. For a better experience, please check out the quick start guide and apply for a personal key."
                  actions:@[
        [SuperXQuickStartAction actionWithTitleZh:@"应用" titleEn:@"Apply" style:1 handler:^{
            [ws applyQuickStartURL:kSXDefaultEndpoint path:kSXDefaultPath
                            model:@"gpt-3.5-turbo" pictureModel:@"gpt-4o"];
        }],
        [SuperXQuickStartAction actionWithTitleZh:@"取消" titleEn:@"Cancel" style:0 handler:nil],
    ]];

    SuperXQuickStartOption *personal = [SuperXQuickStartOption
        optionWithTitleZh:@"使用个人密钥" titleEn:@"Use a personal key"
                messageZh:@"请查看快速上手，申请个人密钥。"
                messageEn:@"Please check the quick start guide and apply for a personal key."
                  actions:@[
        [SuperXQuickStartAction actionWithTitleZh:@"去申请" titleEn:@"Apply now" style:1 handler:^{
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://api.chatanywhere.org"]
                                               options:@{} completionHandler:nil];
        }],
        [SuperXQuickStartAction actionWithTitleZh:@"取消" titleEn:@"Cancel" style:0 handler:nil],
    ]];

    self.quickStartOptions = @[official, personal];
}

- (void)presentFromController:(UIViewController *)controller
                    isChinese:(BOOL)isChinese plistPath:(NSString *)plistPath {
    UIAlertController *sheet = [UIAlertController
        alertControllerWithTitle:isChinese ? @"快速上手" : @"Get started quickly"
                         message:isChinese ? @"选择一种接入方式" : @"Choose how to connect"
                  preferredStyle:UIAlertControllerStyleActionSheet];
    for (SuperXQuickStartOption *o in self.quickStartOptions) {
        [sheet addAction:[UIAlertAction actionWithTitle:(isChinese ? o.titleZh : o.titleEn)
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *x) {
            [self presentQuickStartOption:o fromController:controller isChinese:isChinese];
        }]];
    }
    [sheet addAction:[UIAlertAction actionWithTitle:(isChinese ? @"取消" : @"Cancel")
                                              style:UIAlertActionStyleCancel handler:nil]];
    sheet.popoverPresentationController.sourceView = controller.view;
    [controller presentViewController:sheet animated:YES completion:nil];
}

- (void)presentQuickStartOption:(SuperXQuickStartOption *)option
                 fromController:(UIViewController *)controller isChinese:(BOOL)isChinese {
    UIAlertController *a = [UIAlertController
        alertControllerWithTitle:(isChinese ? option.titleZh : option.titleEn)
                         message:(isChinese ? option.messageZh : option.messageEn)
                  preferredStyle:UIAlertControllerStyleAlert];
    for (SuperXQuickStartAction *act in option.actions) {
        UIAlertActionStyle st = act.style == 1 ? UIAlertActionStyleDefault : UIAlertActionStyleCancel;
        [a addAction:[UIAlertAction actionWithTitle:(isChinese ? act.titleZh : act.titleEn)
                                              style:st handler:^(UIAlertAction *x) {
            if (act.handler) act.handler();
        }]];
    }
    [controller presentViewController:a animated:YES completion:nil];
}

- (void)applyQuickStartURL:(NSString *)url path:(NSString *)path
                     model:(NSString *)model pictureModel:(NSString *)pictureModel {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:kSXPrefsPath];
    if (!d) d = [NSMutableDictionary dictionary];
    if (url) d[kSXKeyEndpointURL] = url;
    if (path) d[kSXKeyEndpointPath] = path;
    if (model) d[kSXKeySelectModel] = model;
    if (pictureModel) d[@"AI_PICTURE_MODEL"] = pictureModel;
    [d writeToFile:kSXPrefsPath atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.superx.prefsChanged"), NULL, NULL, YES);
}

#pragma mark - 反序列化（供远程配置使用）

- (SuperXQuickStartOption *)quickStartOptionFromDictionary:(NSDictionary *)dict {
    NSMutableArray *acts = [NSMutableArray array];
    for (NSDictionary *ad in dict[@"actions"] ?: @[]) {
        SuperXQuickStartAction *a = [self quickStartActionFromDictionary:ad];
        if (a) [acts addObject:a];
    }
    return [SuperXQuickStartOption optionWithTitleZh:dict[@"titleZh"] ?: @""
                                                titleEn:dict[@"titleEn"] ?: @""
                                              messageZh:dict[@"messageZh"] ?: @""
                                              messageEn:dict[@"messageEn"] ?: @""
                                                actions:acts];
}

- (SuperXQuickStartAction *)quickStartActionFromDictionary:(NSDictionary *)dict {
    if (!dict) return nil;
    return [SuperXQuickStartAction actionWithTitleZh:dict[@"titleZh"] ?: @""
                                                titleEn:dict[@"titleEn"] ?: @""
                                                  style:[dict[@"style"] integerValue]
                                                handler:nil];
}

@end
