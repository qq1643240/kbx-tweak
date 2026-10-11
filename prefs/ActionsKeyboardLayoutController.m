#import "ActionsKeyboardLayoutController.h"
#import "SXConstants.h"

@implementation ActionsKeyboardLayoutController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"键盘布局", @"Keyboard Layout");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"键盘布局", @"Keyboard Layout")
                                               footerText:nil]];
        [specs addObject:[self createListCellWithNamed:SXLocalized(@"弹窗宽度", @"Popup width")
                                                   key:@"popupWidth"
                                                titles:@[SXLocalized(@"自适应", @"Auto"), SXLocalized(@"半屏", @"Half"), SXLocalized(@"全宽", @"Full")]
                                                values:@[@0, @1, @2]
                                                iconSF:@"rectangle" default:0]];
        [specs addObject:[self createListCellWithNamed:SXLocalized(@"弹窗高度", @"Popup height")
                                                   key:@"windowHeightScale"
                                                titles:@[SXLocalized(@"小", @"Small"), SXLocalized(@"中", @"Medium"), SXLocalized(@"大", @"Large")]
                                                values:@[@0, @1, @2]
                                                iconSF:@"rectangle.expand.vertical" default:0]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
