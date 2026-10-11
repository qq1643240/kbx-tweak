#import "SXScreenshotIconLoader.h"
#import "SXConstants.h"

static NSArray<NSString *> *SXFallbackSymbols(void) {
    return @[@"doc.on.doc", @"square.and.arrow.down", @"xmark.circle",
             @"pencil.tip.crop.circle", @"questionmark.circle", @"globe.americas"];
}

@implementation SXScreenshotIconLoader

+ (instancetype)shared {
    static SXScreenshotIconLoader *s; static dispatch_once_t once;
    dispatch_once(&once, ^{ s = [SXScreenshotIconLoader new]; });
    return s;
}

+ (UIImage *)imageForAction:(NSString *)name scale:(CGFloat)scale {
    if (!name.length) return nil;
    NSString *suffix = scale >= 3 ? @"@3x" : (scale >= 2 ? @"@2x" : @"");
    NSArray<NSString *> *dirs = @[
        [kSXActionIconDir stringByAppendingPathComponent:@"icon"],
        [kSXActionIconDir stringByAppendingPathComponent:@"iconDefault"],
        kSXActionIconDir,
    ];
    for (NSString *d in dirs) {
        NSString *p = [NSString stringWithFormat:@"%@/action_SuperX_%@%@.png", d, name, suffix];
        UIImage *img = [UIImage imageWithContentsOfFile:p];
        if (img) return img;
    }
    return nil;
}

+ (UIImage *)imageForAction:(NSString *)name {
    return [self imageForAction:name scale:UIScreen.mainScreen.scale];
}

+ (UIImage *)iconTokenForPersona:(NSString *)persona fallbackIndex:(NSInteger)idx {
    UIImage *img = [self imageForAction:persona];
    if (img) return img;
    NSArray *syms = SXFallbackSymbols();
    NSString *sym = syms[labs(idx) % syms.count];
    return [UIImage systemImageNamed:sym];
}

@end
