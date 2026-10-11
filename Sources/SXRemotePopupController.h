//
//  SXRemotePopupController.h
//  远程（宿主 App 侧）弹窗的 SpringBoard 端控制器。
//  负责：发起桥请求 → 等待 ack → 超时回落本地弹窗 → 转发事件。
//

#import <UIKit/UIKit.h>
#import "SXPopupBridge.h"
#import "SXPopupView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SXRemotePopupController : NSObject <SXPopupBridgeDelegate, SXPopupViewDelegate>

+ (instancetype)shared;

@property (nonatomic, strong, nullable) SXPopupView *popupView;
@property (nonatomic, copy,   nullable) NSString *sessionID;
@property (nonatomic, assign) BOOL remoteVisible;
@property (nonatomic, assign) BOOL closingRemote;
@property (nonatomic, copy,   nullable) NSString *remoteText;
@property (nonatomic, copy,   nullable) NSString *remoteSource;
@property (nonatomic, copy,   nullable) NSString *remoteSnapper;
@property (nonatomic, strong, nullable) NSError *remoteError;
@property (nonatomic, assign) BOOL localFallback;
@property (nonatomic, assign) BOOL streaming;

/// 在主窗口呈现 AI 结果（优先走宿主 App，超时回落本地）
- (void)presentText:(NSString *)text isError:(BOOL)isError isSnapperAction:(BOOL)snapper;
- (void)appendStreamText:(NSString *)delta;
- (void)dismiss;
- (void)prepareForNextResult;

/// 把替换文本回传给键盘侧
- (void)forwardReplaceWithText:(nullable NSString *)text;
- (void)notifyKeyboardReplace:(nullable NSString *)text;

@end

NS_ASSUME_NONNULL_END
