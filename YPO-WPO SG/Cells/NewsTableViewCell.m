//
//  NewsTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NewsTableViewCell.h"
#import "YPOArticle.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface NewsTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *newsImageView;
@property (weak, nonatomic) IBOutlet UILabel *newsTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *authorLabel;
@property (weak, nonatomic) IBOutlet UILabel *datePostedLabel;

@end


@implementation NewsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Hack to remove autolayout warning prior to iOS 8.0 when subviews with fixed width using autolayout
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)layoutSubviews {
    [super layoutSubviews];
    [self.newsImageView sd_setImageWithURL:[NSURL URLWithString:self.article.imageURL]];
}


- (void)setArticle:(YPOArticle *)article {
    _article = article;
    self.newsTitleLabel.text = self.article.title;
    self.authorLabel.text = self.article.author;
    self.datePostedLabel.text = [self.article.postDate stringWithFormat:DateWithWeekday];    
}


@end
