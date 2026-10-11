//
//  SXRequest.h
//  AI 请求客户端：文本 / 图片 → 模型；支持流式增量回调。
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^SXStreamBlock)(NSString *delta, BOOL finished);
typedef void (^SXErrorBlock)(NSError *error);
typedef void (^SXModelsBlock)(NSArray<NSString *> *models, NSError *_Nullable error);

@interface SXRequest : NSObject

+ (instancetype)shared;

/// 发送文本。prompt 为空时使用默认人设。
- (void)sendText:(NSString *)text prompt:(nullable NSString *)prompt
        stream:(SXStreamBlock)stream error:(SXErrorBlock)error;

/// 发送图片（JPEG/PNG Data），走多模态。
- (void)sendImage:(NSData *)imageData prompt:(nullable NSString *)prompt
           stream:(SXStreamBlock)stream error:(SXErrorBlock)error;

/// 拉取模型列表（GET {endpoint}/{path}）
- (void)fetchModels:(SXModelsBlock)completion;

/// 取消当前请求
- (void)cancel;

@end

NS_ASSUME_NONNULL_END
