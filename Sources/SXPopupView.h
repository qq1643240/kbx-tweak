//
//  SXPopupView.h
//  键盘上方 AI 结果弹窗（原版 ZAKIPK / C_SXRemotePopupController 的 UI 部分）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SXPopupStyle) {
    SXPopupStyleIsland = 0,   // 灵动岛水滴
    SXPopupStyleWindow,       // 全屏动画
    SXPopupStyleNone,         // 不要动画
};

@class SXPopupView;

@protocol SXPopupViewDelegate <NSObject>
@optional
- (void)popupDidTapReplace:(SXPopupView *)v;
- (void)popupDidTapCopy:(SXPopupView *)v;
- (void)popupDidTapCancel:(SXPopupView *)v;
- (void)popupDidTapSave:(SXPopupView *)v;
- (void)popupDidTapMark:(SXPopupView *)v;
- (void)popupDidTapClose:(SXPopupView *)v;
- (void)popupDidTapTranslate:(SXPopupView *)v;
- (void)popupDidTapOpenLink:(SXPopupView *)v url:(NSURL *)url;
@end

@interface SXPopupView : UIView

- (instancetype)initWithHostView:(UIView *)host;
@property (nonatomic, weak) id<SXPopupViewDelegate> delegate;

@property (nonatomic, copy)   NSString *text;
@property (nonatomic, assign) BOOL isErrorState;
@property (nonatomic, assign) BOOL isSnapperAction;
@property (nonatomic, assign) BOOL streaming;

/// 外观（面板可配）
@property (nonatomic, strong) UIColor *tokenBackgroundColor;
@property (nonatomic, strong) UIColor *tokenTextColor;
@property (nonatomic, strong) UIColor *selectedTokenBackgroundColor;
@property (nonatomic, strong) UIColor *selectedTokenTextColor;
@property (nonatomic, assign) NSInteger buttonColorIndex;
@property (nonatomic, assign) NSInteger buttonFontColorIndex;
@property (nonatomic, assign) NSInteger blurStyle;
@property (nonatomic, assign) CGFloat cornerRadius;
@property (nonatomic, assign) CGFloat borderCornerRadius;

@property (nonatomic, copy) NSString *confirmTitle;        // 默认「替换」
@property (nonatomic, copy) NSString *replaceTitle;
@property (nonatomic, copy) NSString *clipboardButtonTitle; // 默认「复制」
@property (nonatomic, copy) NSString *cancelTitle;          // 默认「取消」
@property (nonatomic, copy) NSString *openLinkTitle;

/// 呈现 / 更新 / 收起
- (void)presentText:(NSString *)text isError:(BOOL)isError isSnapperAction:(BOOL)snapper;
- (void)appendStreamText:(NSString *)delta;
- (void)dismiss;
- (void)dismissImmediately;

/// 布局（供动画器查询）
- (CGFloat)preferredContentHeightForWidth:(CGFloat)width;
- (CGRect)popupFrameForWidth:(CGFloat)w totalHeight:(CGFloat)h hostView:(UIView *)host;
- (BOOL)isNearBottomWithTolerance:(CGFloat)tol;

@end

NS_ASSUME_NONNULL_END
