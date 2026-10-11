//
//  SXPopupBridge.h
//  SpringBoard ↔ 宿主 App 的弹窗桥。
//  原版通过 Darwin 通知 + URL scheme 双向通信，本文件复刻该协议。
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SXPopupBridgeDelegate <NSObject>
@optional
- (void)bridgeDidReceiveCommand:(NSString *)command payload:(NSDictionary *)payload;
- (void)bridgeDidReceiveAck:(NSDictionary *)payload;
- (void)bridgeDidTimeOutForSession:(NSString *)session sequence:(NSUInteger)sequence;
@end

@interface SXPopupBridge : NSObject

+ (instancetype)shared;

@property (nonatomic, weak) id<SXPopupBridgeDelegate> delegate;
/// 超过该时长未收到 ack 即回落到本地弹窗（原版行为）
@property (nonatomic, assign) NSTimeInterval ackTimeout;   // 默认 0.8s

/// 向宿主 App 发起弹窗请求
- (void)presentWithPayload:(NSDictionary *)payload;
/// 通知宿主 App 收起
- (void)dismissWithSession:(NSString *)session;
/// 心跳，保持弹窗存活
- (void)heartbeatWithSession:(NSString *)session;

/// 向宿主 App 回传事件（replace / copy / cancel / closing / dismissed …）
- (void)sendEvent:(NSString *)event session:(NSString *)session extra:(nullable NSDictionary *)extra;

@end

NS_ASSUME_NONNULL_END
