#import "ActionsKbDictationController.h"
#import "SXConstants.h"

@implementation ActionsKbDictationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"听写键", @"Dictation Key");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"听写键", @"Dictation Key")
                                               footerText:nil]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"用听写键触发 AI", @"Use dictation key to trigger AI")
                                                      subtitle:@""
                                                           key:@"wantsDictationTrigger"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"隐藏听写键", @"Hide dictation key")
                                                      subtitle:@""
                                                           key:@"hideDictationKey"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
