//
//  YPONotification.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPONotification.h"


@implementation YPONotification

@dynamic comment;
@dynamic notificationID;
@dynamic postDate;
@dynamic thumbURL;
@dynamic title;
@dynamic type;
@dynamic startDate;
@dynamic endDate;
@dynamic sorting;
@dynamic articleID;
@dynamic articleTitle;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.notificationID = dictionary[@"id"];
    self.type           = dictionary[@"type"];
    self.title          = dictionary[@"title"];
    self.thumbURL       = dictionary[@"thumb_url"];
    NSString *postDate  = dictionary[@"post_date"];
    if (postDate) {
        self.postDate   = [NSDate dateFromString:postDate format:ISODateTimeFormat];
    }
    
    NSString *startDate = dictionary[@"start_date"];
    if (startDate) {
        self.startDate  = [NSDate dateFromString:startDate format:ISODateTimeFormat];
    }
    
    NSString *endDate   = dictionary[@"end_date"];
    if (endDate) {
        self.endDate    = [NSDate dateFromString:endDate format:ISODateTimeFormat];
    }
    
    NSString *sorting   = dictionary[@"sorting"];
    if (sorting) {
        self.sorting    = [NSDate dateFromString:sorting format:ISODateTimeFormat];
    }
    
    self.comment        = dictionary[@"comment"];
    
    NSNumber *articleID = dictionary[@"article_id"];
    if (articleID) {
        self.articleID = articleID;
    }
    
    NSString *articleTitle = dictionary[@"article_title"];
    if (articleTitle) {
        self.articleTitle = articleTitle;
    }
    
}


+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPONotificationRequest *request = [[YPONotificationRequest alloc] init];
    request.cancellationToken = cancellationToken;
    request.function = @"notification.list";
    return request;
}


+ (void)purgeData {
    NSFetchRequest *fetchRequest = [YPONotification MR_requestAllSortedBy:@"sorting" ascending:NO];
    NSError *error;
    YPONotification *last = [[[NSManagedObjectContext MR_defaultContext] executeFetchRequest:fetchRequest error:&error] lastObject];
    if (!error && last) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"sorting < %@", last.sorting];
        NSArray *oldNotifications = [YPONotification MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        for (YPONotification *notification in oldNotifications) {
            [notification MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
        }
    }
}

@end


@implementation YPONotificationRequest

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
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"notificationID == %@ && type == %@", raw[@"id"], raw[@"type"]];
                YPONotification * notification = [YPONotification MR_findFirstWithPredicate:predicate inContext:localContext];
                if (notification == nil) {
                    notification = [YPONotification MR_createEntityInContext:localContext];
                }
                [notification parseDictionary:raw];
            }
        }];
    }
}



@end
