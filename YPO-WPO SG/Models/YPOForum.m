//
//  YPOForum.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOForum.h"
#import "YPOMember.h"


@implementation YPOForum

@dynamic forumID;
@dynamic name;
@dynamic members;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.forumID    = dictionary[@"forum_id"];
    self.name       = dictionary[@"name"];
}


+ (YPOHTTPRequest *)constructRequest {
    YPOForumRequest *request = [[YPOForumRequest alloc] init];
    request.function = @"forums.list";
    return request;
}

@end


@implementation YPOForumRequest


- (void)loadJSONObject:(id)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPOForum * forum = [YPOForum MR_findFirstByAttribute:@"forumID" withValue:raw[@"forum_id"] inContext:localContext];
                if (forum == nil) {
                    forum = [YPOForum MR_createEntityInContext:localContext];
                }
                [forum parseDictionary:raw];
            }
        }];
    }
}


- (void)endLoadJSON:(id)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext  ) {
            NSArray *data = jsonObject[@"data"];
            NSArray *forumID = [data valueForKey:@"forum_id"];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"NOT (forumID IN %@)", forumID];
            NSArray *orphan = [YPOForum MR_findAllWithPredicate:predicate inContext:localContext];
            for (YPOForum *forum in orphan) {
                [forum MR_deleteEntityInContext:localContext];
            }
        }];
    }
}

@end
