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
@dynamic comments;

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
    self.postDate           = [NSDate dateFromString:postDate format:ISODateTimeFormat];
    NSString *created       = dictionary[@"created"];
    self.created            = [NSDate dateFromString:created format:ISODateTimeFormat];
    self.createdBy          = dictionary[@"created_by"];    
}


+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPOArticleRequest *request = [[YPOArticleRequest alloc] init];
    request.cancellationToken = cancellationToken;
    request.function = @"news.list";
    return request;
}

@end


@implementation YPOArticleRequest

- (id)init {
    self = [super init];
    if (self) {
        self.page = 1;
        self.rowCount = 15;
    }
    return self;
}


- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[super params]];
    [params setObject:@(self.page) forKey:@"page"];
    [params setObject:@(self.rowCount) forKey:@"row_count"];
    return params;
}


- (void)loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPOArticle * article = [YPOArticle MR_findFirstByAttribute:@"articleID" withValue:raw[@"article_id"] inContext:localContext];
                if (article == nil) {
                    article = [YPOArticle MR_createEntityInContext:localContext];
                }
                [article parseDictionary:raw];
            }
        }];
    }
}


@end

