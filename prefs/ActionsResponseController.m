#import "ActionsResponseController.h"
#import "SXConstants.h"

@implementation ActionsResponseController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = SXLocalized(@"回答处理", @"Response Method");
}

- (NSArray *)specifiers {
    if (!_specifiers) {
        NSMutableArray *specs = [NSMutableArray array];
        [specs addObject:[self createGroupCellWithLabel:SXLocalized(@"回答处理", @"Response Method")
                                               footerText:SXLocalized(@"回答内容的处理方法", @"Handling method for AI responses")]];
        [specs addObject:[self createListCellWithNamed:SXLocalized(@"默认处理方式", @"Default method")
                                                   key:@"responseMethod"
                                                titles:@[SXLocalized(@"替换", @"Replace"), SXLocalized(@"复制", @"Copy"), SXLocalized(@"仅展示", @"Show only")]
                                                values:@[@0, @1, @2]
                                                iconSF:@"arrow.triangle.branch" default:0]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"流式输出", @"Streaming")
                                                      subtitle:@""
                                                           key:@"streaming"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"流式自动滚底", @"Auto scroll while streaming")
                                                      subtitle:@""
                                                           key:@"streamAutoScrollEnabled"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"自动打开首个链接", @"Auto open first URL")
                                                      subtitle:@""
                                                           key:@"autoOpenFirstURL"
                                                  defaultValue:NO
                                                        iconSF:@"circle"]];
        [specs addObject:[self subtitleSwitchSpecifierWithName:SXLocalized(@"出错时本地回落", @"Local fallback on error")
                                                      subtitle:@""
                                                           key:@"localFallback"
                                                  defaultValue:YES
                                                        iconSF:@"circle"]];

        [self applySFIconsToSpecifiers:specs];
        _specifiers = specs;
    }
    return _specifiers;
}

@end
