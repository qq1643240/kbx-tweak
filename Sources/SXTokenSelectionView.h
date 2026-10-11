//
//  SXTokenSelectionView.h
//  分词选择面板（原版 ZRMZZU / ZRMZZUItem / CopyTokenMiscController 的展示层）
//

#import <UIKit/UIKit.h>
#import "SXTokenItem.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SXTokenSelectionViewDelegate <NSObject>
@optional
- (void)tokenSelectionDidTapSearch:(NSString *)query;
- (void)tokenSelectionDidTapClear;
- (void)tokenSelectionDidTapReset;
- (void)tokenSelectionDidChange:(NSArray<SXTokenItem *> *)items;
@end

@interface SXTokenSelectionView : UIView

@property (nonatomic, weak) id<SXTokenSelectionViewDelegate> delegate;
@property (nonatomic, copy) NSArray<SXTokenItem *> *items;
@property (nonatomic, assign) BOOL tokenSelectionModeEnabled;
@property (nonatomic, assign) BOOL useSelectionSequenceOrder;

@property (nonatomic, strong) UIColor *tokenBackgroundColor;
@property (nonatomic, strong) UIColor *tokenTextColor;
@property (nonatomic, strong) UIColor *selectedTokenBackgroundColor;
@property (nonatomic, strong) UIColor *selectedTokenTextColor;

@property (nonatomic, strong) UIButton *tokenSelectionSearchButton;
@property (nonatomic, strong) UIButton *tokenSelectionClearButton;
@property (nonatomic, strong) UIButton *tokenSelectionResetButton;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)rebuildTokenButtons;
- (void)toggleTokenSelectionMode;
- (nullable SXTokenItem *)tokenAtPoint:(CGPoint)p inView:(UIView *)v;
- (NSInteger)indexOfTokenAtPoint:(CGPoint)p;
- (CGFloat)estimatedTokenSelectionContentHeightForText:(NSString *)t contentWidth:(CGFloat)w;

/// 把选中项按顺序拼成文本（供「替换」使用）
- (NSString *)composedText;

@end

NS_ASSUME_NONNULL_END
