#import "ActionsKeyboardTriggerController.h"
#import "SXConstants.h"

@implementation ActionsKeyboardTriggerController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"微键盘触发", @"Keyboard Trigger");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"微键盘触发", @"Keyboard Trigger")
                                               footerText:SXLocalized(@"键盘上的触发方式", @"Trigger from the keyboard")]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"听写键触发", @"Dictation key trigger")
                                                      subtitle:@""
                                                           key:@"wantsDictationTrigger"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"隐藏听写键", @"Hide dictation key")
                                                      subtitle:@""
                                                           key:@"hideDictationKey"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"键盘动作键", @"Keyboard action button")
                                                      subtitle:@""
                                                           key:@"wantsKbActionButton"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"长按触发", @"Long press trigger")
                                                      subtitle:@""
                                                           key:@"wantsLongPressTrigger"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
