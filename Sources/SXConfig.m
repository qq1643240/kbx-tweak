#import "SXConfig.h"
#import "SXConstants.h"

@interface SXConfig ()
@property (nonatomic, strong) NSMutableDictionary *prefs;
@end

@implementation SXConfig

+ (instancetype)shared {
    static SXConfig *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXConfig new]; [s reload]; });
    return s;
}

- (void)reload {
    NSMutableDictionary *d = [NSMutableDictionary dictionaryWithContentsOfFile:kSXPrefsPath];
    self.prefs = d ?: [NSMutableDictionary dictionary];
    // 首次运行：写入默认端点与路径
    if (!self.prefs[kSXKeyEndpointURL])  self.prefs[kSXKeyEndpointURL]  = kSXDefaultEndpoint;
    if (!self.prefs[kSXKeyEndpointPath]) self.prefs[kSXKeyEndpointPath] = kSXDefaultPath;
    if (!self.prefs[@"personas"])          self.prefs[@"personas"]          = SXDefaultPersonas();
}

- (id)objectForKey:(NSString *)key { return self.prefs[key]; }

- (void)setObject:(id)value forKey:(NSString *)key {
    if (value) self.prefs[key] = value; else [self.prefs removeObjectForKey:key];
    [self synchronize];
}

- (BOOL)boolForKey:(NSString *)key default:(BOOL)def {
    id v = self.prefs[key]; return v ? [v boolValue] : def;
}
- (NSInteger)integerForKey:(NSString *)key default:(NSInteger)def {
    id v = self.prefs[key]; return v ? [v integerValue] : def;
}
- (NSString *)stringForKey:(NSString *)key { return self.prefs[key]; }

- (void)synchronize {
    [self.prefs writeToFile:kSXPrefsPath atomically:YES];
    // 通知面板刷新
    CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(),
        CFSTR("com.superx.prefsChanged"), NULL, NULL, YES);
}

- (void)resetPreferenceKeys {
    NSMutableDictionary *keep = [NSMutableDictionary dictionary];
    if (self.prefs[@"personas"]) keep[@"personas"] = self.prefs[@"personas"];
    self.prefs = keep;
    [self reload];
    [self synchronize];
}

@end
