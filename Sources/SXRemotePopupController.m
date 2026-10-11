#import "SXRemotePopupController.h"
#import "SXConstants.h"
#import "SXConfig.h"
#import "SXIslandAnimator.h"
#import "SXWindowDismissAnimator.h"
#import "SXWindowAmbientGlowAnimator.h"
#import "SXIslandGeometry.h"

@implementation SXRemotePopupController

+ (instancetype)shared {
    static SXRemotePopupController *s; static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [SXRemotePopupController new];
        [SXPopupBridge shared].delegate = s;
    });
    return s;
}

- (UIWindow *)hostWindow {
    for (UIScene *sc in UIApplication.sharedApplication.connectedScenes) {
        if (![sc isKindOfClass:UIWindowScene.class]) continue;
        for (UIWindow *w in ((UIWindowScene *)sc).windows) if (w.isKeyWindow) return w;
    }
    return UIApplication.sharedApplication.windows.firstObject;
}

#pragma mark - 呈现

- (void)presentText:(NSString *)text isError:(BOOL)isError isSnapperAction:(BOOL)snapper {
    self.remoteText = text; self.remoteError = isError ? [NSError errorWithDomain:@"sx" code:1 userInfo:nil] : nil;
    self.remoteSnapper = snapper ? @"1" : nil;
    self.sessionID = self.sessionID ?: [[NSUUID UUID] UUIDString];

    // 先请求宿主 App 承载
    [[SXPopupBridge shared] presentWithPayload:@{
        kSXFieldSession: self.sessionID,
        kSXFieldText: text ?: @"",
        kSXFieldSnapper: snapper ? @"1" : @"0",
        kSXFieldStreaming: @"0",
    }];
    self.remoteVisible = YES;
    NSLog(@"%@SpringBoard present session=%@ loading=%d", kSXLogPrefix, self.sessionID, !text.length);

    // 未收到 ack 时由 bridge 回调走本地回落
}

- (void)appendStreamText:(NSString *)delta {
    if (!self.popupView) return;
    self.streaming = YES;
    [self.popupView appendStreamText:delta];
}

- (void)dismiss {
    if (!self.sessionID) return;
    self.closingRemote = YES;
    [[SXPopupBridge shared] dismissWithSession:self.sessionID];
    NSLog(@"%@SpringBoard dismissed session=%@", kSXLogPrefix, self.sessionID);
    [self.popupView dismiss];
    [self prepareForNextResult];
}

- (void)prepareForNextResult {
    self.remoteVisible = NO;
    self.streaming = NO;
    self.localFallback = NO;
    self.remoteText = nil;
    self.remoteSnapper = nil;
    self.remoteError = nil;
}

#pragma mark - SXPopupBridgeDelegate

- (void)bridgeDidReceiveAck:(NSDictionary *)payload {
    self.localFallback = NO;
}

- (void)bridgeDidReceiveCommand:(NSString *)command payload:(NSDictionary *)payload {
    if ([command isEqualToString:kSXCmdReplace]) {
        [self forwardReplaceWithText:payload[kSXFieldText]];
    } else if ([command isEqualToString:kSXCmdCopy]) {
        UIPasteboard.generalPasteboard.string = self.remoteText ?: @"";
    } else if ([command isEqualToString:kSXCmdCancel] ||
               [command isEqualToString:kSXCmdClosing] ||
               [command isEqualToString:kSXCmdDismissed]) {
        [self dismiss];
    }
}

- (void)bridgeDidTimeOutForSession:(NSString *)session sequence:(NSUInteger)sequence {
    // 宿主 App 没接住 → 本地弹窗
    self.localFallback = YES;
    [self showLocalPopupWithText:self.remoteText
                         isError:(self.remoteError != nil)
                 isSnapperAction:(self.remoteSnapper != nil)];
}

#pragma mark - 本地回落弹窗

- (void)showLocalPopupWithText:(NSString *)text isError:(BOOL)isError isSnapperAction:(BOOL)snapper {
    UIWindow *win = [self hostWindow];
    if (!win) return;

    if (!self.popupView) {
        self.popupView = [[SXPopupView alloc] initWithHostView:win];
        self.popupView.delegate = self;
        self.popupView.tokenBackgroundColor = [self colorFromPrefs:@"tokenBackgroundColor"
                                                       fallback:[UIColor colorWithWhite:1.0 alpha:0.12]];
        self.popupView.selectedTokenBackgroundColor = [self colorFromPrefs:@"selectedTokenBackgroundColor"
                                                              fallback:[UIColor systemBlueColor]];
    }
    [self.popupView presentText:text isError:isError isSnapperAction:snapper];

    SXPopupStyle style = (SXPopupStyle)[[SXConfig shared] integerForKey:kSXKeyDynamicIsland default:0];
    if (style == SXPopupStyleIsland) {
        SXIslandGeometry *g = [SXIslandGeometry shared];
        [g updateWithHostView:win statusBarTop:CGRectGetHeight(UIApplication.sharedApplication.statusBarFrame)];
        NSArray *paths = [g travelPathsFromIslandToView:self.popupView];
        NSArray *centers = [g travelCentersFromIslandToView:self.popupView];
        SXWindowAmbientGlowAnimator *glow = [SXWindowAmbientGlowAnimator shared];
        NSArray<CALayer *> *layers = [glow installGlowLayers:@[] overlay:win popup:self.popupView];
        [[SXIslandAnimator shared] animateFromIslandToView:self.popupView overlay:win
                                                  glowLayers:layers islandRect:g.islandRect
                                         islandCornerRadius:g.islandCornerRadius
                                                 travelPaths:paths travelCenters:centers
                                               revealStarted:nil completion:nil];
        [glow showAmbientGlowForPopup:self.popupView];
    } else {
        [[SXWindowDismissAnimator shared] animatePopupPresentationForView:self.popupView
                                                                  hostView:win
                                                               targetFrame:self.popupView.frame
                                                usesPseudoLandscapeLayout:NO];
    }
}

- (UIColor *)colorFromPrefs:(NSString *)key fallback:(UIColor *)fb {
    NSString *hex = [[SXConfig shared] stringForKey:key];
    if (hex.length < 6) return fb;
    unsigned int v = 0;
    [[NSScanner scannerWithString:[hex stringByReplacingOccurrencesOfString:@"#" withString:@""]]
        scanHexInt:&v];
    return [UIColor colorWithRed:((v >> 16) & 0xFF) / 255.0
                           green:((v >> 8) & 0xFF) / 255.0
                            blue:(v & 0xFF) / 255.0 alpha:1];
}

#pragma mark - SXPopupViewDelegate

- (void)popupDidTapReplace:(SXPopupView *)v {
    [[SXPopupBridge shared] sendEvent:kSXCmdReplace session:self.sessionID
                                   extra:@{kSXFieldText: v.text ?: @""}];
    [self notifyKeyboardReplace:v.text];
}

- (void)popupDidTapCopy:(SXPopupView *)v {
    UIPasteboard.generalPasteboard.string = v.text ?: @"";
    [[SXPopupBridge shared] sendEvent:kSXCmdCopy session:self.sessionID extra:nil];
}

- (void)popupDidTapCancel:(SXPopupView *)v { [self dismiss]; }

- (void)popupDidTapSave:(SXPopupView *)v { [self saveImageToPhotos:v]; }
- (void)popupDidTapMark:(SXPopupView *)v { [self openSnapper3WithImage:nil]; }
- (void)popupDidTapClose:(SXPopupView *)v { [self dismiss]; }
- (void)popupDidTapTranslate:(SXPopupView *)v { }

- (void)popupDidTapOpenLink:(SXPopupView *)v url:(NSURL *)url {
    [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
}

- (void)saveImageToPhotos:(SXPopupView *)v {
    NSLog(@"%@save image requested (需接入 PHPhotoLibrary 写入权限流程)", kSXLogPrefix);
}

- (void)openSnapper3WithImage:(UIImage *)image {
    // 标注插件不可用时给出原版同款提示
    NSString *zh = @"无法找到标注插件，请确保已安装来了老弟的标记插件。";
    NSString *en = @"Annotation plugin not found. Please install the Snapper3 plugin.";
    UIAlertController *a = [UIAlertController alertControllerWithTitle:@"标注功能不可用"
                                                              message:SXLocalized(zh, en)
                                                       preferredStyle:UIAlertControllerStyleAlert];
    [a addAction:[UIAlertAction actionWithTitle:@"去安装" style:UIAlertActionStyleDefault handler:^(UIAlertAction *x) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kSXSnapper3Sileo]
                                           options:@{} completionHandler:nil];
    }]];
    [a addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [[self hostWindow].rootViewController presentViewController:a animated:YES completion:nil];
}

- (void)notifyKeyboardReplace:(NSString *)text {
    [self forwardReplaceWithText:text];
}

/// 把替换文本回传给键盘侧
- (void)forwardReplaceWithText:(NSString *)text {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"com.superx.replaceText"
                                                        object:nil
                                                      userInfo:@{@"text": text ?: @""}];
}

@end
