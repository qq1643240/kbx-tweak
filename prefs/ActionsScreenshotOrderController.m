#import "ActionsScreenshotOrderController.h"
#import "SXConstants.h"

@implementation ActionsScreenshotOrderController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"截图动作排序", @"Screenshot Action Order");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"截图动作排序", @"Screenshot Action Order")
                                               footerText:SXLocalized(@"拖拽调整顺序", @"Drag to reorder")]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置顺序", @"Reset order")
                                                  action:@selector(resetOrder)
                                                  iconSF:@"list.number"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
