#import "ActionsAppTriggerController.h"
#import "SXConstants.h"

@implementation ActionsAppTriggerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"应用触发", @"App Trigger");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"应用触发", @"App Trigger")
                                               footerText:SXLocalized(@"一些App的快速文本处理 (TG包括Telegram,Swiftgram,Nicegram)", @"Quick text processing for some apps (TG includes Telegram, Swiftgram, Nicegram)")]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"Telegram", @"Telegram")
                                                      subtitle:@""
                                                           key:@"triggerTG"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"Swiftgram", @"Swiftgram")
                                                      subtitle:@""
                                                           key:@"triggerSwiftgram"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"Nicegram", @"Nicegram")
                                                      subtitle:@""
                                                           key:@"triggerNicegram"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"在应用内显示悬浮按钮", @"Show floating button in app")
                                                      subtitle:@""
                                                           key:@"wantsAppFloating"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
