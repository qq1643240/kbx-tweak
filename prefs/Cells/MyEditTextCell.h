//
//  MyEditTextCell.h
//  单行文本编辑 Cell（原版同名）
//

#import <Preferences/Preferences.h>

NS_ASSUME_NONNULL_BEGIN

@interface MyEditTextCell : PSEditableTableCell
@property (nonatomic, strong, nullable) UILabel *subtitleLabel;
@end

NS_ASSUME_NONNULL_END
