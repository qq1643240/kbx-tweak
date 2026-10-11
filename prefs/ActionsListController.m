#import "ActionsListController.h"
#import "SXConstants.h"

@implementation ActionsListController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"动作列表", @"Actions");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"动作", @"Actions")
                                               footerText:SXLocalized(@"可拖拽排序", @"Drag to reorder")]];
        [specs addObject:[self subtitleLinkSpecifierWithName:SXLocalized(@"截图动作排序", @"Screenshot action order")
                                                    subtitle:@""
                                                      detail:@"ActionsScreenshotOrderController"
                                                      iconSF:@"square.and.arrow.down"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:SXLocalized(@"Snapper3 联动", @"Snapper3")
                                                    subtitle:SXLocalized(@"来了老弟的标记插件", @"Snapper3 annotation plugin")
                                                      detail:@"ActionsSnapper3Controller"
                                                      iconSF:@"pencil.tip.crop.circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"启用动作条", @"Enable action bar")
                                                      subtitle:@""
                                                           key:@"wantsActionBar"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"使用选择顺序", @"Use selection sequence order")
                                                      subtitle:@""
                                                           key:@"useSelectionSequenceOrder"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
