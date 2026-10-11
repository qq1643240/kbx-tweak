#import "ActionsSnapper3Controller.h"
#import "SXConstants.h"

@implementation ActionsSnapper3Controller

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"Snapper3 联动", @"Snapper3");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"Snapper3 联动", @"Snapper3")
                                               footerText:SXLocalized(@"需要安装 cn.llld.biaoji", @"Requires cn.llld.biaoji")]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"启用 Snapper3 联动", @"Enable Snapper3")
                                                      subtitle:@""
                                                           key:@"wantsSnapper3"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"标记后自动发送", @"Auto send after marking")
                                                      subtitle:@""
                                                           key:@"snapperAutoSend"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleButtonSpecifierWithName:SXLocalized(@"前往安装", @"Install Snapper3")
                                                      subtitle:@""
                                                        action:@selector(goToSileoMarkTweak)
                                                        iconSF:@"arrow.down.circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
