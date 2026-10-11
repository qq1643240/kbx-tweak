#import "SXTokenItem.h"

@implementation SXTokenItem
+ (instancetype)itemWithText:(NSString *)text range:(NSRange)range {
    SXTokenItem *i = [SXTokenItem new];
    i.text = text; i.range = range; i.order = -1; i.selected = NO; i.buttonIndex = -1;
    return i;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"<Token %@ %@ order=%ld>", self.text,
            NSStringFromRange(self.range), (long)self.order];
}
@end
