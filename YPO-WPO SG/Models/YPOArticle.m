//
//  YPOArticle.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOArticle.h"


@implementation YPOArticle

@dynamic articleID;
@dynamic slug;
@dynamic imageURL;
@dynamic title;
@dynamic synopsis;
@dynamic content;
@dynamic author;
@dynamic postDate;
@dynamic created;
@dynamic createdBy;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.articleID          = dictionary[@"article_id"];
    self.slug               = dictionary[@"slug"];
    self.imageURL           = dictionary[@"image_url"];
    self.title              = dictionary[@"title"];
    self.synopsis           = dictionary[@"synopsis"];
    self.content            = dictionary[@"content"];
    self.author             = dictionary[@"author"];
    NSString *postDate      = dictionary[@"post_date"];
    self.postDate           = [NSDate dateFromInternetDateTimeString:postDate formatHint:DateFormatHintRFC3339];
    NSString *created       = dictionary[@"created"];
    self.created            = [NSDate dateFromInternetDateTimeString:created formatHint:DateFormatHintRFC3339];
    self.createdBy          = dictionary[@"created_by"];    
}


+ (YPOHTTPRequest *)constructRequest {
    YPOHTTPRequest *request = [super constructRequest];
    request.apiPath = @"news.list";
    return request;
}

@end
