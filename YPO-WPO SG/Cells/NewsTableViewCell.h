//
//  NewsTableViewCell.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YPOArticle;

@interface NewsTableViewCell : UITableViewCell

@property (nonatomic, strong) YPOArticle *article;

@end
