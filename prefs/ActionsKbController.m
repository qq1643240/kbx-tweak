#import "ActionsKbController.h"
#import "SXConstants.h"

@implementation ActionsKbController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"键盘设置", @"Keyboard");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"键盘设置", @"Keyboard")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"自定义键盘按钮", @"Custom keyboard button")
                                                      subtitle:@""
                                                           key:@"wantsKbButton"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"跟随键盘高度", @"Follow keyboard height")
                                                      subtitle:@""
                                                           key:@"followKeyboardHeight"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
