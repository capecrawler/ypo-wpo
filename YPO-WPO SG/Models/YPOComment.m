//
//  YPOComment.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOComment.h"
#import "YPOArticle.h"
#import "YPOAPIClient.h"


@implementation YPOComment

@dynamic commentID;
@dynamic comment;
@dynamic name;
@dynamic profilePictureURL;
@dynamic postDate;
@dynamic article;
@synthesize memberID;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.commentID          = dictionary[@"comment_id"];
    self.comment            = dictionary[@"comment"];
    self.name               = dictionary[@"name"];
    self.profilePictureURL  = dictionary[@"profile_picture_url"];
    NSString *postDate      = dictionary[@"post_date"];
    self.postDate           = [NSDate dateFromInternetDateTimeString:postDate formatHint:DateFormatHintRFC3339];
}


- (void)saveToRemote {
    [self saveToRemoteSucess:nil failure:nil];
}

- (void)saveToRemoteSucess:(void (^)(NSURLSessionDataTask *task, id responseObject))success
                   failure:(void (^)(NSURLSessionDataTask *task, NSError *error)) failure {
    YPOAddCommentRequest *request = [[YPOAddCommentRequest alloc] init];
    request.function = @"news.comment";
    request.memberID = self.memberID;
    request.comment = self.comment;
    request.articleID = self.article.articleID;
    [request startRequestSuccess:success failure:failure];
}





+ (YPOCommentRequest *)constructRequest {
    YPOCommentRequest *request = [[YPOCommentRequest alloc] init];
    request.function = @"news.comments.list";
    return request;
}

@end


@implementation YPOCommentRequest

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
    [params setObject:self.articleID forKey:@"article_id"];
    return params;
}


- (void) loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            YPOArticle * article = [YPOArticle MR_findFirstByAttribute:@"articleID" withValue:self.articleID inContext:localContext];
            for (NSDictionary *raw in data) {
                YPOComment * comment = [YPOComment MR_findFirstByAttribute:@"commentID" withValue:raw[@"comment_id"] inContext:localContext];
                if (comment == nil) {
                    comment = [YPOComment MR_createEntityInContext:localContext];
                }
                [comment parseDictionary:raw];
                comment.article = article;
            }
        }];
    }
}


@end



@implementation YPOAddCommentRequest

- (NSDictionary *)params {
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithDictionary:[super params]];
    [params setObject:self.articleID forKey:@"article_id"];
    [params setObject:self.memberID forKey:@"member_id"];
    [params setObject:self.comment forKey:@"comment"];
    return params;
}




@end

