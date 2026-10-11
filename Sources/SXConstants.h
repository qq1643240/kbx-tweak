//
//  SXConstants.h
//  super X —— 常量集中定义
//
//  本工程不含任何激活码 / 授权校验 / 激活流程。
//

#ifndef SXConstants_h
#define SXConstants_h

#import <Foundation/Foundation.h>

#pragma mark - 偏好文件

// 与原版一致，便于继承用户既有配置
static NSString * const kSXPrefsDomain   = @"com.superx";
static NSString * const kSXPrefsPath     = @"/var/mobile/Library/Preferences/com.superx.plist";

#pragma mark - 跨进程通信（SpringBoard <-> 宿主 App）

static NSString * const kSXWindowNotif        = @"com.superx.window.notif";
static NSString * const kSXPopupRequestScheme = @"com.superx.popup.request";
static NSString * const kSXPopupEventScheme   = @"com.superx.popup.event/";
static NSString * const kSXAckFormat          = @"%@/ack/%lu";

// PopupBridge 协议字段
static NSString * const kSXFieldSession    = @"session";
static NSString * const kSXFieldSequence   = @"sequence";
static NSString * const kSXFieldCommand    = @"command";
static NSString * const kSXFieldReply      = @"reply";
static NSString * const kSXFieldSnapshot   = @"snapshot";
static NSString * const kSXFieldText       = @"text";
static NSString * const kSXFieldError      = @"error";
static NSString * const kSXFieldSnapper    = @"snapper";
static NSString * const kSXFieldStreaming  = @"streaming";
static NSString * const kSXFieldAutoScroll = @"autoScroll";
static NSString * const kSXFieldHeightScale= @"heightScale";
static NSString * const kSXFieldSnapperName= @"snapperName";
static NSString * const kSXFieldStyle      = @"style";
static NSString * const kSXFieldEvent      = @"event";

// 命令
static NSString * const kSXCmdPrepare   = @"prepare";
static NSString * const kSXCmdRemove    = @"remove";
static NSString * const kSXCmdHeartbeat = @"heartbeat";
static NSString * const kSXCmdDismiss   = @"dismiss";
static NSString * const kSXCmdDismissed = @"dismissed";
static NSString * const kSXCmdReplace   = @"replace";
static NSString * const kSXCmdCopy      = @"copy";
static NSString * const kSXCmdCancel    = @"cancel";
static NSString * const kSXCmdClosing   = @"closing";
static NSString * const kSXCmdSave      = @"save";
static NSString * const kSXCmdMark      = @"mark";
static NSString * const kSXCmdClose     = @"close";
static NSString * const kSXCmdTranslate = @"translate";
static NSString * const kSXCmdAction    = @"action";
static NSString * const kSXCmdEvent     = @"event";

static NSString * const kSXLogPrefix    = @"[----] [PopupBridge] ";

#pragma mark - AI 后端（默认值，面板可改）

static NSString * const kSXDefaultEndpoint = @"https://api.chatanywhere.org";
static NSString * const kSXDefaultPath     = @"v1/models";
static NSString * const kSXBlacklistURL    = @"https://rootless.002599.xyz/blacklist_sx";

#pragma mark - 偏好键（与原版一致）

static NSString * const kSXKeyAIKey            = @"AI_KEY";
static NSString * const kSXKeySelectModel      = @"AI_SELECT_MODEL";
static NSString * const kSXKeyCustomModels     = @"AI_CUSTOM_MODELS";
static NSString * const kSXKeyCustomSystem     = @"AI_CUSTOM_SYSTEM";
static NSString * const kSXKeyEndpointURL      = @"endPointURL";
static NSString * const kSXKeyEndpointPath     = @"endPointPath";
static NSString * const kSXKeyWindowTopMargin  = @"windowTopMargin";
static NSString * const kSXKeyScreenshotOrder  = @"screenshotButtonOrder";
static NSString * const kSXKeyWantsIconFolder  = @"wantsIconFolder";
static NSString * const kSXKeyIconFolder       = @"icon";
static NSString * const kSXKeyWantsCustomShotIcon = @"wantsCustomScreenshotIcon";
static NSString * const kSXKeyTriggerConversation = @"wantsImageTriggerConversation";
static NSString * const kSXKeyWantsImageToAI   = @"wantsImageToAI";
static NSString * const kSXKeyScreenShotMark   = @"wantsScreenScreenshotActionMark";
static NSString * const kSXKeyShotIconSize     = @"wantsScreenScreenshotActionImageIconSize";
static NSString * const kSXKeyShotButtonGap    = @"wantsScreenScreenshotActionImageButtonGap";
static NSString * const kSXKeyFullScreenAction = @"wantsFullScreenScreenshotAction";
static NSString * const kSXKeyFullScreenBar    = @"fullScreenScreenshotActionBar";
static NSString * const kSXKeyUseSelectionOrder= @"useSelectionSequenceOrder";
static NSString * const kSXKeyStreamAutoScroll = @"streamAutoScrollEnabled";
static NSString * const kSXKeyDynamicIsland    = @"dynamicIslandEnabled";
static NSString * const kSXKeyWindowHeightScale= @"windowHeightScale";
static NSString * const kSXKeyCustomOptions    = @"AI_CUSTOM_SYSTEM";

#pragma mark - 截图动作图标目录

static NSString * const kSXActionIconDir = @"/Library/PreferenceBundles/SuperXPrefs.bundle/actions";

#pragma mark - Snapper3 / 标注插件

static NSString * const kSXSnapper3PluginId = @"S3AnnotationPlugin";
static NSString * const kSXSnapper3Sileo    = @"sileo://package/cn.llld.biaoji";

#pragma mark - 默认人设（原版内置 12 条，逐字复刻）

static inline NSArray<NSDictionary *> *SXDefaultPersonas(void) {
    return @[
        @{@"name": @"中英互译", @"prompt": @"你将担任翻译者，将内容翻译成中文，假如简体中文多则译为英文，不要当作问题来回答。仅提供最终文本。"},
        @{@"name": @"纠错润色", @"prompt": @"你将担任文字校对助手，在不增加篇幅的前提下进行纠错和润色。仅提供最终文本"},
        @{@"name": @"情感风格", @"prompt": @"你将担任高情商表达助手，在不增加篇幅的前提下进行润色。仅提供最终文本"},
        @{@"name": @"情感回应", @"prompt": @"你将担任高情商表达助手，对我发送的内容进行回复。仅提供最终文本"},
        @{@"name": @"风趣风格", @"prompt": @"你将担任幽默风趣的表达助手，在不增加篇幅的前提下进行润色。仅提供最终文本"},
        @{@"name": @"风趣回应", @"prompt": @"你将担任幽默风趣的表达助手，对我发送的内容进行回复。仅提供最终文本"},
        @{@"name": @"错误解读", @"prompt": @"你将担任资深程序员，用中文解释我发送的错误信息。仅提供最终文本"},
        @{@"name": @"概要提取", @"prompt": @"你将担任信息摘要助手，帮我提取重点、压缩字数、保持原意。仅提供最终文本"},
        @{@"name": @"你问我答", @"prompt": @"根据我发送的要求给予简要答复"},
        @{@"name": @"看图取字", @"prompt": @"提取图像中的文字内容。仅提供最终文本"},
        @{@"name": @"看图解答", @"prompt": @"告诉我你对图片的简要理解，假如是选择题，直接给我答案"},
        @{@"name": @"译为中文", @"prompt": @"你将担任翻译者，将内容翻译成中文，不要当作问题来回答。仅提供最终文本"},
    ];
}

#pragma mark - 文案（中/英）

static inline NSString *SXLocalized(NSString *zh, NSString *en) {
    NSString *lang = [NSLocale preferredLanguages].firstObject ?: @"en";
    return [lang hasPrefix:@"zh"] ? zh : en;
}

#pragma mark - 授权（复刻版：恒为已授权）

// 原版此处为 isLicenseActivated 判定 + license/upLicense 读取。
// 复刻版不实现任何校验，直接返回 YES；保留符号以便旧调用点零改动。
static inline BOOL SXIsActivated(void) {
    return YES;
}

#endif /* SXConstants_h */
