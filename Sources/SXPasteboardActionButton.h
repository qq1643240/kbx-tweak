//
//  SXPasteboardActionButton.h
//  复制后浮出的小圆钮（原版 PUSKZG / JYFOAZ 系列）
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SXPasteboardActionButton : UIView

+ (instancetype)shared;

@property (nonatomic, copy, nullable) void (^actionHandler)(NSString *text);

/// 边缘拖动 / 长按 / 点击
@property (nonatomic, strong) UIPanGestureRecognizer *pasteboardButtonPanGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *pasteboardEdgePanGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *pasteboardButtonLongPress;
@property (nonatomic, strong) UITapGestureRecognizer *pasteboardMenuInteraction;

@property (nonatomic, assign) BOOL pasteboardMenuVisible;
@property (nonatomic, assign) BOOL pasteboardButtonEditingMode;
@property (nonatomic, assign) BOOL pasteboardActionCancelledBySlide;

/// 监听剪贴板：出现新文本时浮出
- (void)startObservingPasteboardChanges;
- (void)stopObservingPasteboardChanges;

- (void)showPasteboardActionButtonWithText:(NSString *)text;
- (void)hidePasteboardActionButton;
- (void)showPasteboardActionButtonMenu;

/// 内部
- (void)handlePasteboardChanged;
- (void)handlePasteboardActionButtonTap;
- (void)handlePasteboardActionButtonLongPress:(UILongPressGestureRecognizer *)g;
- (void)handlePasteboardActionButtonPan:(UIPanGestureRecognizer *)g;
- (void)handlePasteboardActionButtonEdgePan:(UIPanGestureRecognizer *)g;
- (void)restartPasteboardActionTimer;
- (void)updatePasteboardActionButtonGradient;
- (void)_enterPasteboardButtonEditMode;

@end

NS_ASSUME_NONNULL_END
