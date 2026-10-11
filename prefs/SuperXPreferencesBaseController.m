#import "SuperXPreferencesBaseController.h"
#import "SXConstants.h"
#import <SafariServices/SafariServices.h>
#import <stdlib.h>
#import <spawn.h>

@implementation SuperXPreferencesBaseController

#pragma mark - 偏好读写

- (NSString *)preferencesPath { return kSXPrefsPath; }

- (NSMutableDictionary *)mutablePreferencesDictionary {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:[self preferencesPath]];
    if (!d) d = [NSMutableDictionary dictionary];
    if (!d[@"personas"]) d[@"personas"] = SXDefaultPersonas();
    if (!d[kSXKeyEndpointURL]) d[kSXKeyEndpointURL] = kSXDefaultEndpoint;
    if (!d[kSXKeyEndpointPath]) d[kSXKeyEndpointPath] = kSXDefaultPath;
    return d;
}

- (NSDictionary *)preferencesDictionary { return [[self mutablePreferencesDictionary] copy]; }

- (void)writePreferencesDictionary:(NSDictionary *)dict {
    [dict writeToFile:[self preferencesPath] atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.superx.prefsChanged"), NULL, NULL, YES);
}

- (id)readPreferenceValue:(PSSpecifier *)specifier {
    NSString *key = specifier.properties[@"key"];
    id v = [self preferencesDictionary][key];
    return v ?: specifier.properties[@"default"];
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
    NSString *key = specifier.properties[@"key"];
    if (!key) return;
    NSMutableDictionary *d = [self mutablePreferencesDictionary];
    d[key] = value;
    [self writePreferencesDictionary:d];
    [super setPreferenceValue:value specifier:specifier];
}

#pragma mark - 重置

- (void)resetPreferenceKeys {
    NSMutableDictionary *d = [self mutablePreferencesDictionary];
    NSMutableDictionary *keep = [NSMutableDictionary dictionary];
    if (d[@"personas"]) keep[@"personas"] = d[@"personas"];
    [keep writeToFile:[self preferencesPath] atomically:YES];
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.superx.prefsChanged"), NULL, NULL, YES);
}

- (void)performReset {
    UIAlertController *a = [UIAlertController
        alertControllerWithTitle:SXLocalized(@"重置内容", @"Reset content")
                         message:SXLocalized(@"友好提示：如果出现错误不知道如何处理，可以点击重置重新开始。",
                                              @"Friendly reminder: If an error occurs and you're unsure how to proceed, you can click reset to start over.")
                  preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"确定", @"OK")
                                          style:UIAlertActionStyleDestructive
                                        handler:^(UIAlertAction *x) {
        [self resetPreferenceKeys];
        [self reloadSpecifiers];
    }]];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"取消", @"Cancel")
                                          style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

- (void)performResetOrder { [self resetOrder]; }

- (void)resetOrder {
    NSMutableDictionary *d = [self mutablePreferencesDictionary];
    [d removeObjectForKey:kSXKeyScreenshotOrder];
    [self writePreferencesDictionary:d];
    [self reloadSpecifiers];
}

- (void)reloadButtonOrder { }

- (void)saveOrder { }

- (void)goToSileoMarkTweak {
    NSURL *u = [NSURL URLWithString:kSXSnapper3Sileo];
    if (!u) return;
    [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
}

#pragma mark - 文案

- (NSString *)localizedTextZh:(NSString *)zh en:(NSString *)en { return SXLocalized(zh, en); }

#pragma mark - Specifier 构造

- (PSSpecifier *)createGroupCellWithLabel:(NSString *)label footerText:(NSString *)footer {
    return [self createGroupCellWithLabel:label footerText:footer centerFooter:NO];
}

- (PSSpecifier *)createGroupCellWithLabel:(NSString *)label footerText:(NSString *)footer
                             centerFooter:(BOOL)center {
    PSSpecifier *s = [PSSpecifier groupSpecifierWithName:label];
    if (footer) [s setProperty:footer forKey:@"footerText"];
    return s;
}

- (PSSpecifier *)createListCellWithNamed:(NSString *)name key:(NSString *)key
                                  titles:(NSArray *)titles values:(NSArray *)values
                                  iconSF:(NSString *)sf {
    return [self createListCellWithNamed:name key:key titles:titles values:values iconSF:sf default:0];
}

- (PSSpecifier *)createListCellWithNamed:(NSString *)name key:(NSString *)key
                                  titles:(NSArray *)titles values:(NSArray *)values
                                  iconSF:(NSString *)sf default:(NSInteger)def {
    PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:name
                                                    target:self
                                                       set:@selector(setPreferenceValue:specifier:)
                                                       get:@selector(readPreferenceValue:)
                                                    detail:NSClassFromString(@"PSListItemsController")
                                                      cell:PSLinkListCell
                                                      edit:nil];
    s.cellType = PSLinkListCell;
    [s setProperty:key forKey:@"key"];
    [s setProperty:titles forKey:@"titles"];
    [s setProperty:values forKey:@"values"];
    [s setProperty:@(def) forKey:@"default"];
    if (sf) [s setProperty:sf forKey:@"iconSF"];
    return s;
}

- (PSSpecifier *)createActionCellWithLabel:(NSString *)label action:(SEL)action iconSF:(NSString *)sf {
    PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:label
                                                    target:self
                                                       set:nil get:nil
                                                    detail:nil
                                                      cell:PSButtonCell
                                                      edit:nil];
    s->action = action;              // PSSpecifier 的 @public ivar
    s.buttonAction = action;         // 文档化属性，PSButtonCell 走这条
    s.cellType = PSButtonCell;
    if (sf) [s setProperty:sf forKey:@"iconSF"];
    return s;
}

- (PSSpecifier *)subtitleSwitchSpecifierWithName:(NSString *)name subtitle:(NSString *)sub
                                             key:(NSString *)key defaultValue:(BOOL)def
                                          iconSF:(NSString *)sf {
    PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:name
                                                    target:self
                                                       set:@selector(setPreferenceValue:specifier:)
                                                       get:@selector(readPreferenceValue:)
                                                    detail:nil
                                                      cell:PSSwitchCell
                                                      edit:nil];
    s.cellType = PSSwitchCell;
    [s setProperty:key forKey:@"key"];
    [s setProperty:@(def) forKey:@"default"];
    [s setProperty:sub forKey:@"subtitle"];
    if (sf) [s setProperty:sf forKey:@"iconSF"];
    return s;
}

- (PSSpecifier *)subtitleButtonSpecifierWithName:(NSString *)name subtitle:(NSString *)sub
                                          action:(SEL)action iconSF:(NSString *)sf {
    PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:name
                                                    target:self
                                                       set:nil get:nil
                                                    detail:nil
                                                      cell:PSButtonCell
                                                      edit:nil];
    s->action = action;
    s.buttonAction = action;
    s.cellType = PSButtonCell;
    [s setProperty:sub forKey:@"subtitle"];
    if (sf) [s setProperty:sf forKey:@"iconSF"];
    return s;
}

- (PSSpecifier *)subtitleLinkSpecifierWithName:(NSString *)name subtitle:(NSString *)sub
                                        detail:(NSString *)detail iconSF:(NSString *)sf {
    PSSpecifier *s = [PSSpecifier preferenceSpecifierNamed:name
                                                    target:self set:nil get:nil
                                                    detail:NSClassFromString(detail)
                                                      cell:PSLinkCell edit:nil];
    s.cellType = PSLinkCell;
    [s setProperty:sub forKey:@"subtitle"];
    if (sf) [s setProperty:sf forKey:@"iconSF"];
    return s;
}

- (void)applySFIconsToSpecifiers:(NSArray<PSSpecifier *> *)specs {
    for (PSSpecifier *s in specs) {
        NSString *sf = [s propertyForKey:@"iconSF"];
        if (sf.length) {
            UIImage *img = [UIImage systemImageNamed:sf];
            if (img) [s setProperty:img forKey:@"iconImage"];
        }
    }
}

#pragma mark - 颜色

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size cornerRadius:(CGFloat)r {
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);
    UIBezierPath *p = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, size.width, size.height)
                                                cornerRadius:r];
    [color setFill]; [p fill];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

- (UIColor *)interpolateColorFrom:(UIColor *)a to:(UIColor *)b ratio:(CGFloat)t {
    CGFloat r1,g1,b1,a1,r2,g2,b2,a2;
    [a getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [b getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    return [UIColor colorWithRed:r1+(r2-r1)*t green:g1+(g2-g1)*t
                            blue:b1+(b2-b1)*t alpha:a1+(a2-a1)*t];
}

- (UIColor *)colorMakeVivid:(UIColor *)c sat:(CGFloat)sat bright:(CGFloat)b {
    CGFloat h,s,v,a;
    if (![c getHue:&h saturation:&s brightness:&v alpha:&a]) return c;
    return [UIColor colorWithHue:h saturation:MIN(1, s * sat) brightness:MIN(1, v * b) alpha:a];
}

- (void)openColorPicker:(id)sender defaultColor:(UIColor *)color {
    UIColorPickerViewController *p = [UIColorPickerViewController new];
    p.selectedColor = color ?: UIColor.systemBlueColor;
    p.delegate = (id)self;
    [self presentViewController:p animated:YES completion:nil];
}

- (void)saveSelectedColor:(UIColor *)color toKey:(NSString *)key {
    CGFloat r,g,b,a;
    [color getRed:&r green:&g blue:&b alpha:&a];
    NSString *hex = [NSString stringWithFormat:@"%02X%02X%02X",
                     (int)(r*255), (int)(g*255), (int)(b*255)];
    NSMutableDictionary *d = [self mutablePreferencesDictionary];
    d[key] = hex;
    [self writePreferencesDictionary:d];
}

- (void)colorPickerViewControllerDidSelectColor:(UIColorPickerViewController *)v {
    [self saveSelectedColor:v.selectedColor toKey:@"lastPickedColor"];
}
- (void)colorPickerViewControllerDidFinish:(UIColorPickerViewController *)v { }

#pragma mark - 解析

- (NSArray *)parseModels:(id)raw {
    if ([raw isKindOfClass:NSArray.class]) return raw;
    if ([raw isKindOfClass:NSString.class])
        return [raw componentsSeparatedByString:@";"];
    return @[];
}

- (NSArray *)parseCustomOptions:(id)raw {
    if ([raw isKindOfClass:NSArray.class]) return raw;
    if ([raw isKindOfClass:NSString.class]) return [raw componentsSeparatedByString:@";"];
    return @[];
}

- (NSArray *)parseCustomOptionEntries:(id)raw {
    NSMutableArray *out = [NSMutableArray array];
    for (NSString *line in [self parseCustomOptions:raw]) {
        NSString *t = [line stringByTrimmingCharactersInSet:
                       [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        if (!t.length) continue;
        NSRange eq = [t rangeOfString:@"="];
        if (eq.location == NSNotFound) [out addObject:@{@"name": t, @"prompt": t}];
        else [out addObject:@{@"name": [t substringToIndex:eq.location],
                              @"prompt": [t substringFromIndex:eq.location + 1]}];
    }
    return out;
}

- (NSArray *)searchEnginesFromConfig {
    return @[@"https://www.google.com/search?q=",
             @"https://www.bing.com/search?q=",
             @"https://www.baidu.com/s?wd="];
}

#pragma mark - 跳转

- (void)presentSafariWithURLString:(NSString *)url {
    NSURL *u = [NSURL URLWithString:url];
    if (!u) return;
    SFSafariViewController *v = [[SFSafariViewController alloc] initWithURL:u];
    [self presentViewController:v animated:YES completion:nil];
}

- (void)safariViewControllerDidFinish:(SFSafariViewController *)c { [c dismissViewControllerAnimated:YES completion:nil]; }

- (void)tipsAlertToRespring {
    UIAlertController *a = [UIAlertController
        alertControllerWithTitle:SXLocalized(@"生效提示", @"Apply")
                         message:SXLocalized(@"是否立即生效？点击确定将重启系统界面，可能会有几秒钟的黑屏。",
                                              @"Do you want to apply immediately? Clicking OK will restart the system interface, which may cause a few seconds of black screen.")
                  preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"确定", @"OK")
                                          style:UIAlertActionStyleDestructive
                                        handler:^(UIAlertAction *x) {
        // iOS 上 system() 不可用，改用 posix_spawn
        pid_t pid = 0;
        extern char **environ;
        char *args[] = {"/usr/bin/killall", "-9", "backboardd", NULL};
        posix_spawn(&pid, "/usr/bin/killall", NULL, NULL, args, environ);
    }]];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"取消", @"Cancel")
                                          style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

@end
