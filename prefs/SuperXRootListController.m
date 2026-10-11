#import "SuperXRootListController.h"
#import "SuperXQuickStartManager.h"
#import "SXConstants.h"

@interface SuperXRootListController ()
@property (nonatomic, strong) NSMutableArray<NSString *> *buttonOrder;
@property (nonatomic, strong) NSMutableArray<NSString *> *completeButtonOrder;
@end

@implementation SuperXRootListController

- (instancetype)init {
    if ((self = [super init])) {
        _buttonOrder = [NSMutableArray array];
        _completeButtonOrder = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"super X";
    [self configureNavigationButtons];
    [self reloadButtonOrder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // ⚠️ 不要在这里同步调用 reloadSpecifiers：
    // PSListController 的 viewWillAppear: 已经在处理重载，此时表视图尚未就绪，
    // 再插一次会在错误的时机触发建 cell → 未识别选择子 → 闪退。
    [self reloadButtonOrder];
}

#pragma mark - Specifiers（与原版条目一一对应）

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];

        // ---- 激活状态：复刻版恒为「已授权」，不再有激活入口 ----
        [specs addObject:[self createGroupCellWithLabel:@"" footerText:nil]];
        PSSpecifier *status = [PSSpecifier preferenceSpecifierNamed:
                                   SXLocalized(@"激活状态", @"Activation Status")
                                                            target:self set:nil get:nil
                                                            detail:nil cell:PSTitleValueCell edit:nil];
        [status setProperty:SXLocalized(@"已授权", @"Activated") forKey:@"value"];
        [status setProperty:@"crown" forKey:@"iconSF"];
        [specs addObject:status];

        // ---- 快速上手 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"快速上手", @"Get started quickly") footerText:nil]];
        [specs addObject:[self subtitleButtonSpecifierWithName:
                           SXLocalized(@"快速上手", @"Get started quickly")
                                                      subtitle:SXLocalized(@"配置向导", @"Setup wizard")
                                                        action:@selector(presentQuickStartMenu)
                                                        iconSF:@"sparkles"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"加入QQ交流群", @"Join QQ group")
                                                    subtitle:@"662885645"
                                                      detail:@"SuperXPreferencesBaseController"
                                                      iconSF:@"person.2"]];
        [specs addObject:[self subtitleButtonSpecifierWithName:
                           SXLocalized(@"跳转Filza查看配置文件", @"View configuration file in Filza")
                                                      subtitle:kSXPrefsPath
                                                        action:@selector(gotoFilza)
                                                        iconSF:@"folder"]];
        [specs addObject:[self subtitleButtonSpecifierWithName:
                           SXLocalized(@"查看配置", @"View Configuration")
                                                      subtitle:@""
                                                        action:@selector(gotoConfig)
                                                        iconSF:@"doc.text"]];

        // ---- 触发设置 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"触发设置", @"Trigger Settings")
                                               footerText:SXLocalized(@"触发方式与趣味功能", @"Trigger methods and fun features")]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"图片触发", @"Image Trigger")
                                                    subtitle:SXLocalized(@"自定义截图选区和图片处理按钮",
                                                                          @"Custom screenshot selection and image processing buttons")
                                                      detail:@"ActionsImageTriggerController"
                                                      iconSF:@"photo"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"应用触发", @"App Trigger")
                                                    subtitle:SXLocalized(@"一些App的快速文本处理 (TG包括Telegram,Swiftgram,Nicegram)",
                                                                          @"Quick text processing for some apps (TG includes Telegram, Swiftgram, Nicegram)")
                                                      detail:@"ActionsAppTriggerController"
                                                      iconSF:@"app.badge"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"微键盘触发", @"Keyboard Trigger")
                                                    subtitle:SXLocalized(@"键盘上的触发方式", @"Trigger from the keyboard")
                                                      detail:@"ActionsKeyboardTriggerController"
                                                      iconSF:@"keyboard"]];

        // ---- 回答处理 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"回答处理", @"Response Method")
                                               footerText:SXLocalized(@"回答内容的处理方法", @"Handling method for AI responses")]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"回答处理", @"Response Method")
                                                    subtitle:SXLocalized(@"替换 / 复制 / 打开链接",
                                                                          @"Replace / Copy / Open link")
                                                      detail:@"ActionsResponseController"
                                                      iconSF:@"arrow.triangle.branch"]];

        // ---- 复制分词 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"复制分词", @"Copy Tokenization") footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"复制后弹出分词按钮", @"Show tokenization button after copying")
                                                      subtitle:@""
                                                           key:@"wantsCopyToken"
                                                  defaultValue:NO
                                                        iconSF:@"text.word.spacing"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"复制分词", @"Copy Tokenization")
                                                    subtitle:SXLocalized(@"分词与选择顺序", @"Tokens and selection order")
                                                      detail:@"ActionsCopyTokenController"
                                                      iconSF:@"textformat.abc"]];

        // ---- AI 模型 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"AI 模型", @"AI models")
                                               footerText:SXLocalized(@"文本模型调用", @"Text Model Invocation")]];
        [specs addObject:[self createListCellWithNamed:SXLocalized(@"文本模型", @"Text Model")
                                                   key:kSXKeySelectModel
                                                titles:@[@"gpt-3.5-turbo", @"gpt-4o-mini", @"gpt-4o"]
                                                values:@[@"gpt-3.5-turbo", @"gpt-4o-mini", @"gpt-4o"]
                                                iconSF:@"cpu" default:0]];
        [specs addObject:[self subtitleButtonSpecifierWithName:
                           SXLocalized(@"API Endpoint URL", @"API Endpoint URL")
                                                      subtitle:[[self preferencesDictionary][kSXKeyEndpointURL] description]
                                                        action:@selector(editEndpoint)
                                                        iconSF:@"link"]];
        [specs addObject:[self subtitleButtonSpecifierWithName:
                           SXLocalized(@"API Endpoint Path", @"API Endpoint Path")
                                                      subtitle:SXLocalized(@"请输入后缀路径，默认 v1/models",
                                                                             @"Please enter the suffix path, default is v1/models")
                                                        action:@selector(editEndpointPath)
                                                        iconSF:@"link.badge.plus"]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"API Key", @"API Key")
                                                  action:@selector(editAPIKey)
                                                  iconSF:@"key"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"可选AI人设", @"Optional AI personas")
                                                    subtitle:SXLocalized(@"请按格式添加,用符号';'间隔",
                                                                          @"Please add according to the format, separated by ';'")
                                                      detail:@"ActionsMiscController"
                                                      iconSF:@"person.crop.circle"]];

        // ---- 其他功能 ----
        [specs addObject:[self createGroupCellWithLabel:
                           SXLocalized(@"其他功能", @"Other Features") footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"解锁120Hz屏幕刷新率,让动画更流畅",
                                         @"Unlock 120Hz screen refresh rate for smoother animations")
                                                      subtitle:@"" key:@"wants120hz" defaultValue:NO
                                                        iconSF:@"waveform.path.ecg"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"模拟省电模式并保持120Hz, 解除温度控制",
                                         @"Simulate power-saving mode and maintain 120Hz, remove temperature control")
                                                      subtitle:@"" key:@"wantsPowerSave120" defaultValue:NO
                                                        iconSF:@"thermometer"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"优化进程的内存和线程优先级",
                                         @"Optimize process memory and thread priority")
                                                      subtitle:@"" key:@"wantsProcOpt" defaultValue:NO
                                                        iconSF:@"memorychip"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"键盘改色", @"Keyboard recoloring")
                                                      subtitle:@"" key:@"wantsKbRecolor" defaultValue:NO
                                                        iconSF:@"paintpalette"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:
                           SXLocalized(@"管理文件夹", @"Manage folders")
                                                    subtitle:@"" detail:@"ActionsMiscController"
                                                      iconSF:@"folder.badge.gearshape"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:
                           SXLocalized(@"不要动画", @"No animation")
                                                      subtitle:@"" key:@"noAnimation" defaultValue:NO
                                                        iconSF:@"nosign"]];
        [specs addObject:[self createListCellWithNamed:
                           SXLocalized(@"动态岛水滴", @"Dynamic Island droplet")
                                                   key:kSXKeyDynamicIsland
                                                titles:@[SXLocalized(@"动态岛水滴", @"Dynamic Island droplet"),
                                                         SXLocalized(@"通信动画", @"Communication animation"),
                                                         SXLocalized(@"不要动画", @"No animation")]
                                                values:@[@0, @1, @2] iconSF:@"drop" default:0]];

        // ---- 底部动作 ----
        [specs addObject:[self createGroupCellWithLabel:@"" footerText:nil]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置内容", @"Reset content")
                                                  action:@selector(performReset)
                                                  iconSF:@"arrow.clockwise"]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置顺序", @"Reset order")
                                                  action:@selector(performResetOrder)
                                                  iconSF:@"list.number"]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重启系统界面", @"Respring")
                                                  action:@selector(tipsAlertToRespring)
                                                  iconSF:@"arrow.triangle.2.circlepath"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

#pragma mark - 导航按钮

- (void)configureNavigationButtons {
    UIBarButtonItem *apply = [[UIBarButtonItem alloc]
        initWithTitle:SXLocalized(@"生效", @"Apply")
                style:UIBarButtonItemStyleDone target:self action:@selector(tipsAlertToRespring)];
    self.navigationItem.rightBarButtonItem = apply;
}

#pragma mark - 顺序管理（拖拽排序）

- (void)reloadButtonOrder {
    NSArray *saved = [self preferencesDictionary][kSXKeyScreenshotOrder];
    self.buttonOrder = [saved isKindOfClass:NSArray.class] ? [saved mutableCopy] : [NSMutableArray array];
}

- (void)reloadSpecifierKeys { [self reloadSpecifiers]; }

- (void)saveOrder {
    NSMutableDictionary *d = [self mutablePreferencesDictionary];
    d[kSXKeyScreenshotOrder] = self.buttonOrder;
    [self writePreferencesDictionary:d];
}

// resetOrder 由基类实现（清空排序键并刷新）

#pragma mark - 单元格编辑（拖拽）

- (UITableViewCellEditingStyle)tableView:(UITableView *)tv editingStyleForRowAtIndexPath:(NSIndexPath *)ip {
    return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tv canMoveRowAtIndexPath:(NSIndexPath *)ip { return YES; }

- (BOOL)tableView:(UITableView *)tv canEditRowAtIndexPath:(NSIndexPath *)ip { return YES; }

- (void)tableView:(UITableView *)tv moveRowAtIndexPath:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to {
    if (from.row >= (NSInteger)self.buttonOrder.count) return;
    id obj = self.buttonOrder[from.row];
    [self.buttonOrder removeObjectAtIndex:from.row];
    [self.buttonOrder insertObject:obj atIndex:MIN((NSUInteger)to.row, self.buttonOrder.count)];
    [self saveOrder];
}

- (NSIndexPath *)tableView:(UITableView *)tv targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)from
       toProposedIndexPath:(NSIndexPath *)proposed {
    return proposed;
}

- (BOOL)tableView:(UITableView *)tv shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)ip { return NO; }

- (NSString *)tableView:(UITableView *)tv titleForFooterInSection:(NSInteger)section { return nil; }

#pragma mark - 快速上手

- (void)presentQuickStartMenu {
    [[SuperXQuickStartManager shared] presentFromController:self isChinese:
        [[NSLocale preferredLanguages].firstObject hasPrefix:@"zh"]
                                                    plistPath:[self preferencesPath]];
}

#pragma mark - 动作

- (void)gotoFilza {
    NSURL *u = [NSURL URLWithString:[@"filza://" stringByAppendingString:[self preferencesPath]]];
    if (u) [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
}

- (void)gotoConfig {
    [self presentSafariWithURLString:[NSString stringWithFormat:@"file://%@", [self preferencesPath]]];
}

- (void)editEndpoint {
    [self promptForText:SXLocalized(@"API Endpoint URL", @"API Endpoint URL")
                   value:[self preferencesDictionary][kSXKeyEndpointURL]
                     key:kSXKeyEndpointURL];
}

- (void)editEndpointPath {
    [self promptForText:SXLocalized(@"API Endpoint Path", @"API Endpoint Path")
                   value:[self preferencesDictionary][kSXKeyEndpointPath]
                     key:kSXKeyEndpointPath];
}

- (void)editAPIKey {
    [self promptForText:SXLocalized(@"API Key", @"API Key")
                   value:[self preferencesDictionary][kSXKeyAIKey]
                     key:kSXKeyAIKey];
}

- (void)promptForText:(NSString *)title value:(NSString *)value key:(NSString *)key {
    UIAlertController *a = [UIAlertController alertControllerWithTitle:title
                                                              message:nil
                                                       preferredStyle:UIAlertControllerStyleAlert];
    [a addTextFieldWithConfigurationHandler:^(UITextField *tf) {
        tf.text = value;
        tf.autocapitalizationType = UITextAutocapitalizationTypeNone;
        tf.autocorrectionType = UITextAutocorrectionTypeNo;
    }];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"确定", @"OK")
                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) {
        NSString *t = a.textFields.firstObject.text ?: @"";
        NSMutableDictionary *d = [self mutablePreferencesDictionary];
        d[key] = t;
        [self writePreferencesDictionary:d];
        [self reloadSpecifiers];
    }]];
    [a addAction:[UIAlertAction actionWithTitle:SXLocalized(@"取消", @"Cancel")
                                          style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:a animated:YES completion:nil];
}

@end
