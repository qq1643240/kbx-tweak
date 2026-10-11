//
//  SuperXDisablePasteTips.xm
//  独立小插件：去掉跨 App 粘贴确认提示。
//  Filter.Executables = druid, pasted
//

#import <UIKit/UIKit.h>
#import <substrate.h>
#import <objc/runtime.h>
#import <dlfcn.h>

static BOOL (*orig_shouldShowPasteAlert)(void) = NULL;

static BOOL sx_hook_shouldShowPasteAlert(void) {
    return NO;
}

%hook UIPasteboard

// 关闭粘贴提示（方法不存在时仅新增，无副作用）
- (BOOL)_pasteboardAlertSuppressionEnabled {
    return YES;
}

%end

%ctor {
    @autoreleasepool {
        // 部分系统版本走 C 入口
        void *sym = dlsym(RTLD_DEFAULT, "UIPasteboardShouldShowPasteAlert");
        if (sym) {
            MSHookFunction(sym, (void *)sx_hook_shouldShowPasteAlert,
                           (void **)&orig_shouldShowPasteAlert);
        }
    }
}
