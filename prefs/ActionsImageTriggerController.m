#import "ActionsImageTriggerController.h"
#import "SXConstants.h"

@implementation ActionsImageTriggerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"图片触发", @"Image Trigger");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"图片触发", @"Image Trigger")
                                               footerText:SXLocalized(@"自定义截图选区和图片处理按钮", @"Custom screenshot selection and image processing buttons")]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"截图后弹出悬浮窗", @"Show floating window after screenshot")
                                                      subtitle:@""
                                                           key:@"wantsFloatingShot"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"自定义截图按钮图标", @"Custom screenshot icon")
                                                      subtitle:@""
                                                           key:@"wantsCustomScreenshotIcon"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"全屏截图动作条", @"Full screen screenshot action bar")
                                                      subtitle:@""
                                                           key:@"wantsFullScreenScreenshotAction"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"截图标注", @"Mark on screenshot")
                                                      subtitle:@""
                                                           key:@"wantsScreenScreenshotActionMark"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"静音截图音效", @"Mute screenshot sound")
                                                      subtitle:@""
                                                           key:@"muteScreenshotSound"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置截图按钮顺序", @"Reset button order")
                                                  action:@selector(performResetOrder)
                                                  iconSF:@"list.number"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
