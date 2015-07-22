//
//  CommentTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "YPOComment.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface CommentTableViewCell()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *bodyLabel;
@property (nonatomic, strong) UILabel *datePostedLabel;
@property (nonatomic, strong) UIImageView *thumbnailView;

@property (nonatomic, strong) NSIndexPath *indexPath;

@property (nonatomic) BOOL usedForMessage;

@end

@implementation CommentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor whiteColor];
        
        [self configureSubviews];
    }
    return self;
}

- (void)configureSubviews {
    [self.contentView addSubview:self.thumbnailView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.bodyLabel];
    [self.contentView addSubview:self.datePostedLabel];
    
    NSDictionary *views = @{@"thumbnailView": self.thumbnailView,
                            @"titleLabel": self.titleLabel,
                            @"datePostedLabel": self.datePostedLabel,
                            @"bodyLabel": self.bodyLabel,
                            };
    
    NSDictionary *metrics = @{@"tumbSize": @(kAvatarSize),
                              @"trailing": @10,
                              @"leading": @5,
                              };
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(tumbSize)]-trailing-[titleLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(tumbSize)]-trailing-[bodyLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-leading-[thumbnailView(tumbSize)]-trailing-[datePostedLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
    
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-trailing-[thumbnailView(tumbSize)]-(>=0)-|" options:0 metrics:metrics views:views]];
    [self.contentView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-15-[titleLabel]-leading-[datePostedLabel]-[bodyLabel(>=0)]-trailing-|" options:0 metrics:metrics views:views]];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.thumbnailView sd_setImageWithURL:[NSURL URLWithString:self.comment.profilePictureURL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        self.thumbnailView.layer.shouldRasterize = YES;
        self.thumbnailView.layer.rasterizationScale = [UIScreen mainScreen].scale;
    }];
}

#pragma mark - Getters

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.userInteractionEnabled = NO;
        _titleLabel.numberOfLines = 0;
        
        _titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        _titleLabel.textColor = [UIColor grayColor];
    }
    return _titleLabel;
}

- (UILabel *)datePostedLabel {
    if (!_datePostedLabel) {
        _datePostedLabel = [UILabel new];
        _datePostedLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _datePostedLabel.backgroundColor = [UIColor clearColor];
        _datePostedLabel.userInteractionEnabled = NO;
        _datePostedLabel.numberOfLines = 1;
        
        _datePostedLabel.font = [UIFont systemFontOfSize:13.0];
        _datePostedLabel.textColor = [UIColor lightGrayColor];
    }
    return _datePostedLabel;
}


- (UILabel *)bodyLabel {
    if (!_bodyLabel) {
        _bodyLabel = [UILabel new];
        _bodyLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _bodyLabel.backgroundColor = [UIColor clearColor];
        _bodyLabel.userInteractionEnabled = NO;
        _bodyLabel.numberOfLines = 0;
        
        _bodyLabel.font = [UIFont systemFontOfSize:16.0];
        _bodyLabel.textColor = [UIColor darkGrayColor];
    }
    return _bodyLabel;
}

- (UIImageView *)thumbnailView {
    if (!_thumbnailView) {
        _thumbnailView = [UIImageView new];
        _thumbnailView.translatesAutoresizingMaskIntoConstraints = NO;
        _thumbnailView.userInteractionEnabled = NO;
        _thumbnailView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        
        _thumbnailView.layer.cornerRadius = kAvatarSize/2.0;
        _thumbnailView.layer.masksToBounds = YES;
    }
    return _thumbnailView;
}

- (void)setComment:(YPOComment *)comment {
    _comment = comment;
    _titleLabel.text = comment.name;
    _bodyLabel.text = comment.comment;
    _datePostedLabel.text = comment.postDateFormatted;
}

@end
