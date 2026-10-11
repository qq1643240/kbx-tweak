#import "SXPopupBridge.h"
#import "SXConstants.h"
#import <UIKit/UIKit.h>

@interface SXPopupBridge ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *pending;
@property (nonatomic, assign) NSUInteger sequence;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@end

@implementation SXPopupBridge

+ (instancetype)shared {
    static SXPopupBridge *s; static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [SXPopupBridge new];
        s.ackTimeout = 0.8;
        s.pending = [NSMutableDictionary dictionary];
        s.sequence = 1;
        [[NSNotificationCenter defaultCenter] addObserver:s
            selector:@selector(handleDarwinNotif:)
            name:kSXWindowNotif object:nil];
    });
    return s;
}

#pragma mark - 发送

- (void)presentWithPayload:(NSDictionary *)payload {
    NSMutableDictionary *p = [payload mutableCopy] ?: [NSMutableDictionary dictionary];
    NSString *session = p[kSXFieldSession] ?: [[NSUUID UUID] UUIDString];
    NSUInteger seq = self.sequence++;
    p[kSXFieldSession]  = session;
    p[kSXFieldSequence] = @(seq);
    p[kSXFieldCommand]  = kSXCmdPrepare;

    self.pending[session] = @(seq);
    [self dispatchPayload:p];

    // 超时回落
    __weak typeof(self) ws = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.ackTimeout * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        typeof(self) ss = ws; if (!ss) return;
        if (ss.pending[session]) {
            [ss.pending removeObjectForKey:session];
            NSLog(@"%@SpringBoard timeout session=%@ sequence=%lu; showing local fallback",
                  kSXLogPrefix, session, (unsigned long)seq);
            if ([ss.delegate respondsToSelector:@selector(bridgeDidTimeOutForSession:sequence:)]) {
                [ss.delegate bridgeDidTimeOutForSession:session sequence:seq];
            }
        }
    });
}

- (void)dismissWithSession:(NSString *)session {
    [self dispatchPayload:@{kSXFieldSession: session ?: @"", kSXFieldCommand: kSXCmdDismiss}];
    [self.heartbeatTimer invalidate]; self.heartbeatTimer = nil;
}

- (void)heartbeatWithSession:(NSString *)session {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer *t) {
        [self dispatchPayload:@{kSXFieldSession: session ?: @"", kSXFieldCommand: kSXCmdHeartbeat}];
    }];
}

- (void)sendEvent:(NSString *)event session:(NSString *)session extra:(NSDictionary *)extra {
    NSMutableDictionary *p = [@{kSXFieldSession: session ?: @"",
                                kSXFieldEvent: event ?: @""} mutableCopy];
    if (extra) [p addEntriesFromDictionary:extra];
    NSString *url = [NSString stringWithFormat:@"%@%@?%@", kSXPopupEventScheme, event,
                     [self queryString:p]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                       options:@{} completionHandler:nil];
}

- (void)dispatchPayload:(NSDictionary *)payload {
    NSData *json = [NSJSONSerialization dataWithJSONObject:payload options:0 error:nil];
    NSString *b64 = [json base64EncodedStringWithOptions:0];
    NSString *url = [NSString stringWithFormat:@"%@?payload=%@", kSXPopupRequestScheme,
                     [b64 stringByAddingPercentEncodingWithAllowedCharacters:
                      [NSCharacterSet URLQueryAllowedCharacterSet]]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]
                                       options:@{} completionHandler:nil];
}

- (NSString *)queryString:(NSDictionary *)d {
    NSMutableArray *pairs = [NSMutableArray array];
    for (NSString *k in d) {
        NSString *v = [d[k] description];
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", k,
                          [v stringByAddingPercentEncodingWithAllowedCharacters:
                           [NSCharacterSet URLQueryAllowedCharacterSet]]]];
    }
    return [pairs componentsJoinedByString:@"&"];
}

#pragma mark - 接收

- (void)handleDarwinNotif:(NSNotification *)n {
    NSDictionary *payload = n.userInfo;
    NSString *cmd = payload[kSXFieldCommand];
    NSString *session = payload[kSXFieldSession];
    if ([cmd isEqualToString:@"ack"]) {
        [self.pending removeObjectForKey:session ?: @""];
        if ([self.delegate respondsToSelector:@selector(bridgeDidReceiveAck:)])
            [self.delegate bridgeDidReceiveAck:payload];
        return;
    }
    if ([self.delegate respondsToSelector:@selector(bridgeDidReceiveCommand:payload:)])
        [self.delegate bridgeDidReceiveCommand:cmd payload:payload];
}

@end
