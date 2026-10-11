#import "ActionsMiscController.h"
#import "SXConstants.h"

@implementation ActionsMiscController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"其他设置", @"Other Settings");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"其他设置", @"Other Settings")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"解锁120Hz屏幕刷新率,让动画更流畅", @"Unlock 120Hz screen refresh rate for smoother animations")
                                                      subtitle:@""
                                                           key:@"wants120hz"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"模拟省电模式并保持120Hz, 解除温度控制", @"Simulate power-saving mode and maintain 120Hz, remove temperature control")
                                                      subtitle:@""
                                                           key:@"wantsPowerSave120"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"优化进程的内存和线程优先级", @"Optimize process memory and thread priority")
                                                      subtitle:@""
                                                           key:@"wantsProcOpt"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"键盘改色", @"Keyboard recoloring")
                                                      subtitle:@""
                                                           key:@"wantsKbRecolor"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleLinkSpecifierWithName:SXLocalized(@"管理文件夹", @"Manage folders")
                                                    subtitle:@""
                                                      detail:@"ActionsMiscController"
                                                      iconSF:@"folder.badge.gearshape"]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置内容", @"Reset content")
                                                  action:@selector(performReset)
                                                  iconSF:@"arrow.clockwise"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
