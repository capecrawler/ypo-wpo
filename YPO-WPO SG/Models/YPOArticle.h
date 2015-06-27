//
//  YPOArticle.h
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"


@interface YPOArticle : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * articleID;
@property (nonatomic, retain) NSString * slug;
@property (nonatomic, retain) NSString * imageURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * synopsis;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSDate * created;
@property (nonatomic, retain) NSNumber * createdBy;

@end


@interface YPOArticleRequest : YPOHTTPRequest

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger rowCount;

@end