#import "MyEditTextCell.h"

@implementation MyEditTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)rid
                    specifier:(PSSpecifier *)specifier {
    if ((self = [super initWithStyle:style reuseIdentifier:rid specifier:specifier])) {
        [self hk_configureWithSpecifier:specifier];
    }
    return self;
}

- (void)hk_configureWithSpecifier:(PSSpecifier *)specifier {
    NSString *sub = [specifier propertyForKey:@"subtitle"];
    if (!sub.length) return;
    if (!self.subtitleLabel) {
        self.subtitleLabel = [UILabel new];
        self.subtitleLabel.font = [UIFont systemFontOfSize:12];
        self.subtitleLabel.textColor = UIColor.secondaryLabelColor;
        self.subtitleLabel.numberOfLines = 2;
        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:self.subtitleLabel];
        [NSLayoutConstraint activateConstraints:@[
            [self.subtitleLabel.leadingAnchor constraintEqualToAnchor:self.textLabel.leadingAnchor],
            [self.subtitleLabel.topAnchor constraintEqualToAnchor:self.textLabel.bottomAnchor constant:1],
            [self.subtitleLabel.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-16],
        ]];
    }
    self.subtitleLabel.text = sub;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self bringSubviewToFront:self.subtitleLabel];
}

@end
