//
//  Tweak.xm — super X 主入口
//
//  本工程不含任何激活码 / 授权校验 / 激活流程。
//

#import <UIKit/UIKit.h>
#import <substrate.h>
#import <objc/runtime.h>
#import "SXConstants.h"
#import "SXConfig.h"
#import "SXRequest.h"
#import "SXRemotePopupController.h"
#import "SXTokenItem.h"
#import "SXTokenSelectionView.h"
#import "SXPasteboardActionButton.h"
#import "SXFloatingScreenshotView.h"
#import "SXIslandGeometry.h"

#pragma mark - 前置声明

static NSArray<SXTokenItem *> *SXCloneTokenize(NSString *text);
static UIImage *SXCloneTakeScreenshot(void);
static void SXCloneShowFloatingScreenshot(UIImage *image, UIWindow *win);

#pragma mark - 全局状态

static NSString *gSXLastSelectedText = nil;
static NSString *gSXLastPrompt = nil;
static UIImage  *gSXLastImage = nil;
static BOOL      gSXSnapperAction = NO;

#pragma mark - 私有类声明（UIKeyboardImpl 不在公开 SDK 中）

@interface UIKeyboardImpl : UIView
- (void)layoutSubviews;
- (void)_reloadInputSwitcherItems;
- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2;
- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 isRunningButton:(BOOL)arg3;
- (BOOL)shouldShowDictationKey;

// 本工程新增
- (void)sendTextToAI:(NSString *)text prompt:(nullable NSString *)prompt;
- (void)sendImageToAI:(UIImage *)image prompt:(nullable NSString *)prompt;
- (void)showTokenSelectionPopup:(NSString *)text;
- (void)showImageTokenSelectionPopup:(UIImage *)image;
- (void)performCopyTokenActionWithText:(NSString *)text actionIndex:(NSInteger)index;

- (void)sx_installActionButtonIfNeeded;
- (void)sx_actionButtonTapped;
- (void)sx_triggerTextAI;
- (nullable NSString *)sx_currentSelectedText;
- (nullable UIView *)sx_findFirstResponder:(UIView *)view;
@end

#pragma mark - UIKeyboardImpl

%hook UIKeyboardImpl

- (void)layoutSubviews {
    %orig;
    [self sx_installActionButtonIfNeeded];
}

- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 {
    if (![[SXConfig shared] boolForKey:@"wantsDictationTrigger" default:YES]) {
        %orig;
        return;
    }
    [self sx_triggerTextAI];
}

- (void)dictationItemButtonWasPressed:(id)arg1 withEvent:(id)arg2 isRunningButton:(BOOL)arg3 {
    if (![[SXConfig shared] boolForKey:@"wantsDictationTrigger" default:YES]) {
        %orig;
        return;
    }
    [self sx_triggerTextAI];
}

- (BOOL)shouldShowDictationKey {
    if ([[SXConfig shared] boolForKey:@"hideDictationKey" default:NO]) return NO;
    return %orig;
}

- (void)_reloadInputSwitcherItems {
    %orig;
    [self sx_installActionButtonIfNeeded];
}

#pragma mark 复刻的对外方法

- (void)sendTextToAI:(NSString *)text prompt:(NSString *)prompt {
    gSXLastSelectedText = text;
    gSXLastPrompt = prompt;

    SXRemotePopupController *c = [SXRemotePopupController shared];
    [c prepareForNextResult];
    [c presentText:@"" isError:NO isSnapperAction:gSXSnapperAction];

    [[SXRequest shared] sendText:text prompt:prompt
                          stream:^(NSString *delta, BOOL finished) {
        [[SXRemotePopupController shared] appendStreamText:delta];
    } error:^(NSError *e) {
        [[SXRemotePopupController shared] presentText:e.localizedDescription
                                              isError:YES isSnapperAction:NO];
    }];
}

- (void)sendImageToAI:(UIImage *)image prompt:(NSString *)prompt {
    gSXLastImage = image;
    gSXLastPrompt = prompt;

    NSData *jpeg = UIImageJPEGRepresentation(image, 0.85);
    SXRemotePopupController *c = [SXRemotePopupController shared];
    [c prepareForNextResult];
    [c presentText:@"" isError:NO isSnapperAction:YES];

    [[SXRequest shared] sendImage:jpeg prompt:prompt
                           stream:^(NSString *delta, BOOL finished) {
        [[SXRemotePopupController shared] appendStreamText:delta];
    } error:^(NSError *e) {
        [[SXRemotePopupController shared] presentText:e.localizedDescription
                                              isError:YES isSnapperAction:YES];
    }];
}

- (void)showTokenSelectionPopup:(NSString *)text {
    gSXLastSelectedText = text;
    NSArray<SXTokenItem *> *items = SXCloneTokenize(text);
    UIWindow *win = UIApplication.sharedApplication.windows.firstObject;
    if (!win) return;

    SXTokenSelectionView *v = [[SXTokenSelectionView alloc] initWithFrame:
        CGRectMake(0, 0, CGRectGetWidth(win.bounds), 220)];
    v.items = items;
    v.tokenSelectionModeEnabled = YES;
    [win addSubview:v];
}

- (void)showImageTokenSelectionPopup:(UIImage *)image {
    [self showTokenSelectionPopup:SXLocalized(@"复制图片", @"Copy Image")];
}

- (void)performCopyTokenActionWithText:(NSString *)text actionIndex:(NSInteger)index {
    UIPasteboard.generalPasteboard.string = text ?: @"";
    NSLog(@"%@copy token action %ld text=%@", kSXLogPrefix, (long)index, text);
}

#pragma mark 私有辅助

- (void)sx_installActionButtonIfNeeded {
    static char kInstalledKey;
    if (objc_getAssociatedObject(self, &kInstalledKey)) return;
    objc_setAssociatedObject(self, &kInstalledKey, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    UIButton *b = [UIButton buttonWithType:UIButtonTypeSystem];
    [b setImage:[UIImage systemImageNamed:@"sparkles"] forState:UIControlStateNormal];
    b.tintColor = UIColor.labelColor;
    b.frame = CGRectMake(6, 6, 34, 34);
    [b addTarget:self action:@selector(sx_actionButtonTapped)
        forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:b];
}

- (void)sx_actionButtonTapped { [self sx_triggerTextAI]; }

- (void)sx_triggerTextAI {
    NSString *text = [self sx_currentSelectedText];
    if (!text.length) text = UIPasteboard.generalPasteboard.string;
    if (!text.length) return;
    [self sendTextToAI:text prompt:nil];
}

- (NSString *)sx_currentSelectedText {
    UIView *fr = [self sx_findFirstResponder:self];
    if ([fr isKindOfClass:UITextView.class]) {
        UITextView *tv = (UITextView *)fr;
        if (tv.selectedRange.length) return [tv.text substringWithRange:tv.selectedRange];
    } else if ([fr isKindOfClass:UITextField.class]) {
        UITextField *tf = (UITextField *)fr;
        UITextRange *r = tf.selectedTextRange;
        if (r && !r.empty) return [tf textInRange:r];
    }
    return nil;
}

- (UIView *)sx_findFirstResponder:(UIView *)view {
    if (view.isFirstResponder) return view;
    for (UIView *s in view.subviews) {
        UIView *r = [self sx_findFirstResponder:s];
        if (r) return r;
    }
    return nil;
}

%end

#pragma mark - 初始化

static void SXPrefsChangedCallback(CFNotificationCenterRef center,
                                   void *observer,
                                   CFStringRef name,
                                   const void *object,
                                   CFDictionaryRef userInfo) {
    [[SXConfig shared] reload];
}

/// 延迟启动：主线程 + 2s，确保 SpringBoard 已完成启动。
/// 绝不能在 %ctor 里碰 UIKit —— 那时 UIKit 尚未初始化，
/// 建视图 / 读 UIPasteboard 会直接把 SpringBoard 干进安全模式。
static void SXStartDeferredServices(void) {
    @autoreleasepool {
        [[SXPasteboardActionButton shared] startObservingPasteboardChanges];
        NSLog(@"%@deferred services started", kSXLogPrefix);
    }
}

%ctor {
    @autoreleasepool {
        // --- 紧急开关：存在该文件则完全不加载，便于从安全模式自救 ---
        if ([[NSFileManager defaultManager] fileExistsAtPath:@"/var/mobile/Library/Preferences/com.superx.disabled"]) {
            NSLog(@"%@disabled by flag file, skipping init", kSXLogPrefix);
            return;
        }

        // --- 只做纯 Foundation 的事，不碰 UIKit ---
        [[SXConfig shared] reload];

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        NULL,
                                        SXPrefsChangedCallback,
                                        CFSTR("com.superx.prefsChanged"),
                                        NULL,
                                        CFNotificationSuspensionBehaviorDeliverImmediately);

        NSLog(@"%@loaded (no UIKit in ctor)", kSXLogPrefix);

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)),
                       dispatch_get_main_queue(), ^{
            SXStartDeferredServices();
        });
    }
}

#pragma mark - 工具函数

/// 分词：按行 + 英文标识符边界切分
static NSArray<SXTokenItem *> *SXCloneTokenize(NSString *text) {
    NSMutableArray<SXTokenItem *> *out = [NSMutableArray array];
    if (!text.length) return out;

    NSMutableArray<NSValue *> *ranges = [NSMutableArray array];

    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                             options:NSStringEnumerationByLines
                          usingBlock:^(NSString *sub, NSRange subRange, NSRange encl, BOOL *stop) {
        if (sub.length) [ranges addObject:[NSValue valueWithRange:subRange]];
    }];

    NSRegularExpression *re = [NSRegularExpression
        regularExpressionWithPattern:@"[A-Za-z_][A-Za-z0-9_]*" options:0 error:nil];
    [re enumerateMatchesInString:text options:0 range:NSMakeRange(0, text.length)
                      usingBlock:^(NSTextCheckingResult *m, NSMatchingFlags f, BOOL *stop) {
        if (m.range.length >= 3) [ranges addObject:[NSValue valueWithRange:m.range]];
    }];

    NSMutableArray<NSNumber *> *occupied = [NSMutableArray array];
    for (NSValue *v in ranges) {
        NSRange r = v.rangeValue;
        BOOL dup = NO;
        for (NSNumber *n in occupied) {
            NSRange prev = NSMakeRange(n.unsignedIntegerValue, 0);
            if (NSLocationInRange(r.location, prev)) { dup = YES; break; }
        }
        if (dup) continue;
        [occupied addObject:@(r.location)];
        [out addObject:[SXTokenItem itemWithText:[text substringWithRange:r] range:r]];
    }
    return out;
}

/// 取当前屏幕截图
static UIImage *SXCloneTakeScreenshot(void) {
    UIWindow *win = nil;
    for (UIScene *sc in UIApplication.sharedApplication.connectedScenes) {
        if (![sc isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *w in ((UIWindowScene *)sc).windows) {
            if (w.isKeyWindow) { win = w; break; }
        }
        if (win) break;
    }
    if (!win) win = UIApplication.sharedApplication.windows.firstObject;
    if (!win) return nil;

    UIGraphicsBeginImageContextWithOptions(win.bounds.size, NO, 0);
    [win drawViewHierarchyInRect:win.bounds afterScreenUpdates:NO];
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

/// 显示悬浮截图小窗
static void SXCloneShowFloatingScreenshot(UIImage *image, UIWindow *win) {
    if (!image || !win) return;
    CGFloat w = CGRectGetWidth(win.bounds) * 0.34;
    CGFloat h = w * image.size.height / MAX(image.size.width, 1);
    CGRect f = CGRectMake(CGRectGetWidth(win.bounds) - w - 16,
                          CGRectGetHeight(win.bounds) - h - 120, w, h);
    SXFloatingScreenshotView *v = [[SXFloatingScreenshotView alloc] initWithImage:image
                                                                           frame:f hostView:win];
    [v showFloatingImage:image frame:f hostView:win menu:nil dismissalHandler:nil];
    [v beginScreenshotWindowLevel];
}

// 供外部（面板/调试）调用截图浮窗
void SXPresentFloatingScreenshot(void) {
    UIWindow *win = UIApplication.sharedApplication.windows.firstObject;
    SXCloneShowFloatingScreenshot(SXCloneTakeScreenshot(), win);
}
