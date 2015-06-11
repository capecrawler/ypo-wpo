//
//  NewsTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NewsTableViewCell.h"

@interface NewsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleView;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;

@end


@implementation NewsTableViewCell

- (void)awakeFromNib {
    // Initialization code
    // Hack to remove autolayout warning prior to iOS 8.0 when subviews with fixed width using autolayout
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
