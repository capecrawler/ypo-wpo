//
//  YPOChapter.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOChapter.h"
#import "YPOMember.h"


@implementation YPOChapter

@dynamic chapterID;
@dynamic name;
@dynamic members;


- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.chapterID = dictionary[@"chapter_id"];
    self.name = dictionary[@"name"];
    
}

+ (YPOHTTPRequest *)constructRequest {
    YPOChapterRequest *request = [[YPOChapterRequest alloc] init];
    request.function = @"chapters.list";
    return request;
}

@end


@implementation  YPOChapterRequest

- (void)loadJSONObject:(NSDictionary *)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPOChapter * chapter = [YPOChapter MR_findFirstByAttribute:@"chapterID" withValue:raw[@"chapter_id"] inContext:localContext];
                if (chapter == nil) {
                    chapter = [YPOChapter MR_createEntityInContext:localContext];
                }
                [chapter parseDictionary:raw];
            }
        }];
    }
}

- (void)endLoadJSON:(id)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext  ) {
            NSArray *data = jsonObject[@"data"];
            NSArray *chapterIDs = [data valueForKey:@"chapter_id"];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"NOT (chapterID IN %@)", chapterIDs];
            NSArray *orphan = [YPOChapter MR_findAllWithPredicate:predicate inContext:localContext];
            for (YPOChapter *chapter in orphan) {
                [chapter MR_deleteEntityInContext:localContext];
            }
        }];
    }
}

@end