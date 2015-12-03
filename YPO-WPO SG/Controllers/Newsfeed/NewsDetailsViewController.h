//
//  NewsDetailsViewController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "BaseViewController.h"
@class YPOArticle;

@interface NewsDetailsViewController : BaseViewController

@property (nonatomic, assign) NSInteger articleID;
@property (nonatomic, strong) NSString *articleTitle;

@end
