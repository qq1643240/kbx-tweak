#import "SXPopupView.h"
#import "SXConstants.h"
#import "SXConfig.h"
#import "SXTokenItem.h"
#import "SXTokenSelectionView.h"

@interface SXPopupView () <UITextViewDelegate>
@property (nonatomic, weak)   UIView *hostView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) UIView *buttonBar;
@property (nonatomic, strong) UIButton *replaceButton;
@property (nonatomic, strong) UIButton *clipboardActionButton;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *openLinkButton;
@property (nonatomic, strong) SXTokenSelectionView *tokenSelectionView;
@property (nonatomic, strong) NSMutableString *streamBuffer;
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) BOOL dismissing;
@end

@implementation SXPopupView

- (instancetype)initWithHostView:(UIView *)host {
    if ((self = [super initWithFrame:CGRectZero])) {
        _hostView = host;
        _streamBuffer = [NSMutableString string];
        _cornerRadius = 16.0;
        _borderCornerRadius = 16.0;
        _blurStyle = 2; // UIBlurEffectStyleDark 系
        _confirmTitle = @"替换";
        _replaceTitle = @"替换";
        _clipboardButtonTitle = @"复制";
        _cancelTitle = @"取消";
        _openLinkTitle = @"打开链接";
        _tokenBackgroundColor = [UIColor colorWithWhite:1.0 alpha:0.12];
        _tokenTextColor = UIColor.whiteColor;
        _selectedTokenBackgroundColor = [UIColor systemBlueColor];
        _selectedTokenTextColor = UIColor.whiteColor;
        [self setupSubviews];
    }
    return self;
}

#pragma mark - 构建

- (void)setupSubviews {
    self.backgroundColor = UIColor.clearColor;

    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:(UIBlurEffectStyle)self.blurStyle];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    self.blurEffectView.translatesAutoresizingMaskIntoConstraints = NO;
    self.blurEffectView.layer.cornerRadius = self.cornerRadius;
    self.blurEffectView.layer.masksToBounds = YES;
    [self addSubview:self.blurEffectView];

    self.contentView = [UIView new];
    self.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.blurEffectView.contentView addSubview:self.contentView];

    self.textView = [UITextView new];
    self.textView.translatesAutoresizingMaskIntoConstraints = NO;
    self.textView.backgroundColor = UIColor.clearColor;
    self.textView.editable = NO;
    self.textView.scrollEnabled = YES;
    self.textView.font = [UIFont systemFontOfSize:15];
    self.textView.textColor = UIColor.labelColor;
    self.textView.textContainerInset = UIEdgeInsetsMake(8, 8, 8, 8);
    self.textView.delegate = self;
    [self.contentView addSubview:self.textView];

    self.buttonBar = [UIView new];
    self.buttonBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.contentView addSubview:self.buttonBar];

    self.replaceButton        = [self buttonWithTitle:self.replaceTitle        action:@selector(onReplace)];
    self.clipboardActionButton= [self buttonWithTitle:self.clipboardButtonTitle action:@selector(onCopy)];
    self.cancelButton         = [self buttonWithTitle:self.cancelTitle         action:@selector(onCancel)];
    self.openLinkButton       = [self buttonWithTitle:self.openLinkTitle       action:@selector(onOpenLink)];
    self.openLinkButton.hidden = YES;

    [NSLayoutConstraint activateConstraints:@[
        [self.blurEffectView.topAnchor constraintEqualToAnchor:self.topAnchor],
        [self.blurEffectView.bottomAnchor constraintEqualToAnchor:self.bottomAnchor],
        [self.blurEffectView.leadingAnchor constraintEqualToAnchor:self.leadingAnchor],
        [self.blurEffectView.trailingAnchor constraintEqualToAnchor:self.trailingAnchor],

        [self.contentView.topAnchor constraintEqualToAnchor:self.blurEffectView.contentView.topAnchor],
        [self.contentView.bottomAnchor constraintEqualToAnchor:self.blurEffectView.contentView.bottomAnchor],
        [self.contentView.leadingAnchor constraintEqualToAnchor:self.blurEffectView.contentView.leadingAnchor],
        [self.contentView.trailingAnchor constraintEqualToAnchor:self.blurEffectView.contentView.trailingAnchor],

        [self.textView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:4],
        [self.textView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:4],
        [self.textView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-4],

        [self.buttonBar.topAnchor constraintEqualToAnchor:self.textView.bottomAnchor constant:4],
        [self.buttonBar.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:8],
        [self.buttonBar.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-8],
        [self.buttonBar.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-8],
        [self.buttonBar.heightAnchor constraintEqualToConstant:34],
    ]];
}

- (UIButton *)buttonWithTitle:(NSString *)title action:(SEL)sel {
    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setTitle:title forState:UIControlStateNormal];
    b.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    b.translatesAutoresizingMaskIntoConstraints = NO;
    [self.buttonBar addSubview:b];
    return b;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutBottomButtonsForViewWidth:CGRectGetWidth(self.bounds)];
}

/// 底部按钮等宽排布
- (void)layoutBottomButtonsForViewWidth:(CGFloat)viewWidth {
    NSMutableArray<UIButton *> *visible = [NSMutableArray array];
    for (UIButton *b in @[self.replaceButton, self.clipboardActionButton,
                          self.openLinkButton, self.cancelButton]) {
        if (!b.hidden) [visible addObject:b];
    }
    if (!visible.count) return;
    CGFloat gap = 8.0, total = viewWidth - 16.0 - gap * (visible.count - 1);
    CGFloat w = total / visible.count;
    CGFloat x = 0;
    for (UIButton *b in visible) {
        b.frame = CGRectMake(x, 0, w, 34);
        x += w + gap;
    }
}

#pragma mark - 呈现

- (void)presentText:(NSString *)text isError:(BOOL)isError isSnapperAction:(BOOL)snapper {
    self.text = text;
    self.isErrorState = isError;
    self.isSnapperAction = snapper;
    self.textView.text = text ?: @"";
    [self.streamBuffer setString:text ?: @""];
    self.openLinkButton.hidden = ([self firstURLInText:text] == nil);
    self.presenting = YES;

    CGFloat hostW = CGRectGetWidth(self.hostView.bounds);
    CGFloat w = [self popupWidthForHostView:self.hostView];
    CGFloat h = [self preferredContentHeightForWidth:w];
    self.frame = [self popupFrameForWidth:w totalHeight:h hostView:self.hostView];
    [self.hostView addSubview:self];
    [self.hostView bringSubviewToFront:self];
    [self setNeedsLayout];
}

- (void)appendStreamText:(NSString *)delta {
    if (!delta.length) return;
    [self.streamBuffer appendString:delta];
    self.textView.text = self.streamBuffer;
    // 流式自动滚底
    if ([[SXConfig shared] boolForKey:kSXKeyStreamAutoScroll default:YES]) {
        [self.textView scrollRangeToVisible:NSMakeRange(self.textView.text.length, 0)];
    }
    [self refreshLayout];
}

- (void)refreshLayout {
    CGFloat w = CGRectGetWidth(self.bounds);
    CGFloat h = [self preferredContentHeightForWidth:w];
    CGRect f = self.frame; f.size.height = h;
    self.frame = f;
}

- (void)dismiss {
    if (self.dismissing) return;
    self.dismissing = YES;
    [UIView animateWithDuration:0.18 animations:^{
        self.alpha = 0;
        self.transform = CGAffineTransformMakeScale(0.92, 0.92);
    } completion:^(BOOL f) { [self removeFromSuperview]; self.dismissing = NO; }];
}

- (void)dismissImmediately { [self removeFromSuperview]; }

#pragma mark - 尺寸

- (CGFloat)preferredContentHeightForWidth:(CGFloat)width {
    CGFloat textW = width - 16;
    CGSize fit = [self.textView sizeThatFits:CGSizeMake(textW, CGFLOAT_MAX)];
    CGFloat content = MAX(44.0, MIN(fit.height + 16.0, 240.0));
    return content + 34 + 16;   // 文本 + 按钮条 + 内边距
}

- (CGFloat)popupWidthForHostView:(UIView *)host {
    CGFloat w = CGRectGetWidth(host.bounds);
    BOOL landscape = w > CGRectGetHeight(host.bounds);
    return landscape ? MIN(w * 0.5, 420) : w - 16;
}

- (CGRect)popupFrameForWidth:(CGFloat)w totalHeight:(CGFloat)h hostView:(UIView *)host {
    CGFloat hostW = CGRectGetWidth(host.bounds);
    CGFloat top = [[SXConfig shared] integerForKey:kSXKeyWindowTopMargin default:8];
    CGFloat x = (hostW - w) / 2.0;
    return CGRectMake(x, top, w, h);
}

- (CGRect)popupFrameForWidth:(CGFloat)w totalHeight:(CGFloat)h
                    hostView:(UIView *)host statusBarTop:(CGFloat)statusTop {
    CGRect f = [self popupFrameForWidth:w totalHeight:h hostView:host];
    f.origin.y = MAX(f.origin.y, statusTop + 4);
    return f;
}

- (CGFloat)popupOriginXForWidth:(CGFloat)w hostView:(UIView *)host {
    return (CGRectGetWidth(host.bounds) - w) / 2.0;
}

- (BOOL)isNearBottomWithTolerance:(CGFloat)tol {
    UIScrollView *sv = self.textView;
    CGFloat maxOff = MAX(0, sv.contentSize.height - CGRectGetHeight(sv.bounds));
    return (maxOff - sv.contentOffset.y) <= tol;
}

- (BOOL)isLandscapeLayoutForHostView:(UIView *)host {
    return CGRectGetWidth(host.bounds) > CGRectGetHeight(host.bounds);
}

- (BOOL)shouldUsePseudoLandscapeLayoutForHostView:(UIView *)host {
    return NO;
}

- (CGFloat)popupRotationAngleForHostView:(UIView *)host { return 0; }

- (CGSize)presentationBoundsSizeForHostView:(UIView *)host { return host.bounds.size; }

- (CGFloat)availableHeightForHostView:(UIView *)host {
    return CGRectGetHeight(host.bounds) * 0.6;
}
- (CGFloat)availablePopupHeightForHostView:(UIView *)host {
    return [self availableHeightForHostView:host];
}

#pragma mark - 链接

- (NSURL *)firstURLInText:(NSString *)text {
    NSDataDetector *d = [NSDataDetector dataDetectorWithTypes:NSTextCheckingTypeLink error:nil];
    NSTextCheckingResult *m = [d firstMatchInString:text ?: @"" options:0
                                              range:NSMakeRange(0, (text ?: @"").length)];
    return m.URL;
}

- (void)onOpenLink {
    NSURL *u = [self firstURLInText:self.streamBuffer];
    if (u && [self.delegate respondsToSelector:@selector(popupDidTapOpenLink:url:)])
        [self.delegate popupDidTapOpenLink:self url:u];
    else if (u) [[UIApplication sharedApplication] openURL:u options:@{} completionHandler:nil];
}

#pragma mark - 按钮

- (void)onReplace  { if ([self.delegate respondsToSelector:@selector(popupDidTapReplace:)])  [self.delegate popupDidTapReplace:self];  }
- (void)onCopy     { if ([self.delegate respondsToSelector:@selector(popupDidTapCopy:)])     [self.delegate popupDidTapCopy:self];     }
- (void)onCancel   { if ([self.delegate respondsToSelector:@selector(popupDidTapCancel:)])   [self.delegate popupDidTapCancel:self];   }
- (void)onSave     { if ([self.delegate respondsToSelector:@selector(popupDidTapSave:)])     [self.delegate popupDidTapSave:self];     }
- (void)onMark     { if ([self.delegate respondsToSelector:@selector(popupDidTapMark:)])     [self.delegate popupDidTapMark:self];     }
- (void)onClose    { if ([self.delegate respondsToSelector:@selector(popupDidTapClose:)])    [self.delegate popupDidTapClose:self];    }
- (void)onTranslate{ if ([self.delegate respondsToSelector:@selector(popupDidTapTranslate:)])[self.delegate popupDidTapTranslate:self]; }

@end
