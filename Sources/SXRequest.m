#import "SXRequest.h"
#import "SXConfig.h"
#import "SXConstants.h"

@interface SXRequest () <NSURLSessionDataDelegate>
@property (nonatomic, strong) NSURLSession *session;
@property (nonatomic, strong) NSURLSessionDataTask *task;
@property (nonatomic, copy) SXStreamBlock streamBlock;
@property (nonatomic, copy) SXErrorBlock errorBlock;
@property (nonatomic, strong) NSMutableString *buffer;
@property (nonatomic, strong) NSMutableData *rawBuffer;
@end

@implementation SXRequest

+ (instancetype)shared {
    static SXRequest *s; static dispatch_once_t once;
    dispatch_once(&once, ^{
        s = [SXRequest new];
        NSURLSessionConfiguration *c = [NSURLSessionConfiguration defaultSessionConfiguration];
        c.timeoutIntervalForRequest = 60;
        c.timeoutIntervalForResource = 300;
        s.session = [NSURLSession sessionWithConfiguration:c delegate:s delegateQueue:nil];
    });
    return s;
}

- (NSString *)endpoint {
    NSString *e = [[SXConfig shared] stringForKey:kSXKeyEndpointURL] ?: kSXDefaultEndpoint;
    return [e hasSuffix:@"/"] ? [e substringToIndex:e.length - 1] : e;
}
- (NSString *)model {
    return [[SXConfig shared] stringForKey:kSXKeySelectModel] ?: @"gpt-3.5-turbo";
}
- (NSString *)apiKey {
    return [[SXConfig shared] stringForKey:kSXKeyAIKey] ?: @"";
}
- (NSString *)systemPromptWith:(NSString *)prompt {
    if (prompt.length) return prompt;
    NSString *custom = [[SXConfig shared] stringForKey:kSXKeyCustomSystem];
    return custom.length ? custom : @"You are a helpful assistant.";
}

#pragma mark - 发送

- (void)sendText:(NSString *)text prompt:(NSString *)prompt
          stream:(SXStreamBlock)stream error:(SXErrorBlock)error {
    NSArray *messages = @[
        @{@"role": @"system", @"content": [self systemPromptWith:prompt]},
        @{@"role": @"user",   @"content": text ?: @""},
    ];
    [self postMessages:messages stream:stream error:error];
}

- (void)sendImage:(NSData *)imageData prompt:(NSString *)prompt
           stream:(SXStreamBlock)stream error:(SXErrorBlock)error {
    NSString *b64 = [imageData base64EncodedStringWithOptions:0];
    NSArray *content = @[
        @{@"type": @"text", @"text": [self systemPromptWith:prompt]},
        @{@"type": @"image_url", @"image_url": @{@"url": [@"data:image/jpeg;base64," stringByAppendingString:b64]}},
    ];
    NSArray *messages = @[
        @{@"role": @"system", @"content": [self systemPromptWith:prompt]},
        @{@"role": @"user",   @"content": content},
    ];
    [self postMessages:messages stream:stream error:error];
}

- (void)postMessages:(NSArray *)messages stream:(SXStreamBlock)stream error:(SXErrorBlock)error {
    self.streamBlock = stream; self.errorBlock = error;
    self.buffer = [NSMutableString string]; self.rawBuffer = [NSMutableData data];

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/v1/chat/completions", [self endpoint]]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    req.HTTPMethod = @"POST";
    [req setValue:[@"Bearer " stringByAppendingString:[self apiKey]] forHTTPHeaderField:@"Authorization"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    req.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{
        @"model": [self model],
        @"messages": messages,
        @"stream": @YES,
    } options:0 error:nil];

    self.task = [self.session dataTaskWithRequest:req];
    [self.task resume];
}

- (void)fetchModels:(SXModelsBlock)completion {
    NSString *path = [[SXConfig shared] stringForKey:kSXKeyEndpointPath] ?: kSXDefaultPath;
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@", [self endpoint], path]];
    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:url];
    [req setValue:[@"Bearer " stringByAppendingString:[self apiKey]] forHTTPHeaderField:@"Authorization"];
    [[self.session dataTaskWithRequest:req completionHandler:^(NSData *d, NSURLResponse *r, NSError *e) {
        if (e) { completion(@[], e); return; }
        id json = [NSJSONSerialization JSONObjectWithData:d options:0 error:nil];
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *m in json[@"data"] ?: @[]) {
            if (m[@"id"]) [names addObject:m[@"id"]];
        }
        completion(names, nil);
    }] resume];
}

- (void)cancel { [self.task cancel]; self.task = nil; }

#pragma mark - NSURLSessionDataDelegate（流式解析 SSE）

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task
   didReceiveData:(NSData *)data {
    [self.rawBuffer appendData:data];
    NSString *chunk = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!chunk) return;
    [self.buffer appendString:chunk];

    NSArray<NSString *> *lines = [self.buffer componentsSeparatedByString:@"\n"];
    for (NSUInteger i = 0; i + 1 < lines.count; i++) {
        NSString *line = [lines[i] stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceCharacterSet]];
        if (![line hasPrefix:@"data:"]) continue;
        NSString *payload = [[line substringFromIndex:5]
                             stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([payload isEqualToString:@"[DONE]"]) {
            if (self.streamBlock) self.streamBlock(@"", YES);
            continue;
        }
        id json = [NSJSONSerialization JSONObjectWithData:[payload dataUsingEncoding:NSUTF8StringEncoding]
                                                  options:0 error:nil];
        NSString *delta = json[@"choices"][0][@"delta"][@"content"];
        if (delta.length && self.streamBlock) self.streamBlock(delta, NO);
    }
    self.buffer = [[lines lastObject] mutableCopy] ?: [NSMutableString string];
}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task
didCompleteWithError:(NSError *)error {
    if (error && error.code != NSURLErrorCancelled && self.errorBlock) self.errorBlock(error);
}

// 与原版一致：无条件接受服务器证书（自建中转无需证书链）。
// 若要收紧，请改为系统默认校验，并让用户安装根证书。
- (void)URLSession:(NSURLSession *)session didReceiveChallenge:(NSURLAuthenticationChallenge *)challenge
 completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential *))handler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        handler(NSURLSessionAuthChallengeUseCredential,
                [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust]);
    } else {
        handler(NSURLSessionAuthChallengePerformDefaultHandling, nil);
    }
}

@end
