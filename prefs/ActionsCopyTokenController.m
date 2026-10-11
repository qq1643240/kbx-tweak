#import "ActionsCopyTokenController.h"
#import "SXConstants.h"

@implementation ActionsCopyTokenController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"复制分词", @"Copy Tokenization");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"复制分词", @"Copy Tokenization")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"复制后弹出分词按钮", @"Show tokenization button after copying")
                                                      subtitle:@""
                                                           key:@"wantsCopyToken"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"按选择顺序拼接", @"Compose by selection order")
                                                      subtitle:@""
                                                           key:@"useSelectionSequenceOrder"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self createListCellWithNamed:SXLocalized(@"分词粒度", @"Granularity")
                                                   key:@"tokenGranularity"
                                                titles:@[SXLocalized(@"英文标识符", @"English identifier"), SXLocalized(@"中英混合", @"Mixed"), SXLocalized(@"整行", @"Whole line")]
                                                values:@[@0, @1, @2]
                                                iconSF:@"textformat.abc" default:0]];
        [specs addObject:[self createActionCellWithLabel:SXLocalized(@"重置分词设置", @"Reset tokenization")
                                                  action:@selector(performReset)
                                                  iconSF:@"arrow.clockwise"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
