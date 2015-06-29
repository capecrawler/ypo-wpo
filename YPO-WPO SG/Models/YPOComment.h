//
//  YPOComment.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

@class YPOArticle;

@interface YPOComment : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber      *commentID;
@property (nonatomic, retain) NSString      *comment;
@property (nonatomic, retain) NSString      *name;
@property (nonatomic, retain) NSString      *profilePictureURL;
@property (nonatomic, retain) NSDate        *postDate;
@property (nonatomic, retain) YPOArticle    *article;

@end


@interface YPOCommentRequest : YPOHTTPRequest

@property (nonatomic, assign) NSUInteger    page;
@property (nonatomic, assign) NSUInteger    rowCount;
@property (nonatomic, strong) NSNumber      *articleID;

@end