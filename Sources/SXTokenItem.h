//
//  SXTokenItem.h
//  分词项模型（原版 SuperXTokenItem）
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXTokenItem : NSObject
@property (nonatomic, copy)   NSString *text;
@property (nonatomic, assign) NSRange   range;       // 在源文本中的范围
@property (nonatomic, assign) NSInteger order;       // 选择顺序（-1 表示未选）
@property (nonatomic, assign) BOOL      selected;
@property (nonatomic, assign) NSInteger buttonIndex; // 对应按钮序号
+ (instancetype)itemWithText:(NSString *)text range:(NSRange)range;
@end

NS_ASSUME_NONNULL_END
