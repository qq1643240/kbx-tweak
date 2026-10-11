#import "CopyTokenMiscController.h"
#import "SXConstants.h"

@implementation CopyTokenMiscController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"分词杂项", @"Copy Token Misc");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"分词杂项", @"Copy Token Misc")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"分词按钮悬浮", @"Floating token button")
                                                      subtitle:@""
                                                           key:@"tokenButtonFloating"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"保留标点", @"Keep punctuation")
                                                      subtitle:@""
                                                           key:@"keepPunctuation"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
