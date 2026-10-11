#import "ActionsKbDockController.h"
#import "SXConstants.h"

@implementation ActionsKbDockController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"键盘 Dock", @"Keyboard Dock");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"键盘 Dock", @"Keyboard Dock")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"在 Dock 上显示 AI 键", @"Show AI key on Dock")
                                                      subtitle:@""
                                                           key:@"wantsKbDockButton"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
