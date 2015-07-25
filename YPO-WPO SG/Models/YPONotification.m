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

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.notificationID = dictionary[@"id"];
    self.type           = dictionary[@"type"];
    self.title          = dictionary[@"title"];
    self.thumbURL       = dictionary[@"thumb_url"];
    NSString *postDate  = dictionary[@"post_date"];
    if (postDate) {
        self.postDate   = [NSDate dateFromInternetDateTimeString:postDate formatHint:DateFormatHintRFC3339];
    }
    
    NSString *startDate = dictionary[@"start_date"];
    if (startDate) {
        self.startDate  = [NSDate dateFromInternetDateTimeString:startDate formatHint:DateFormatHintRFC3339];
    }
    
    NSString *endDate   = dictionary[@"end_date"];
    if (endDate) {
        self.endDate    = [NSDate dateFromInternetDateTimeString:endDate formatHint:DateFormatHintRFC3339];
    }
    
    NSString *sorting   = dictionary[@"sorting"];
    if (sorting) {
        self.sorting    = [NSDate dateFromInternetDateTimeString:sorting formatHint:DateFormatHintRFC3339];
    }
    
    self.comment        = dictionary[@"comment"];
    
}


+ (YPOHTTPRequest *)constructRequest {
    YPONotificationRequest *request = [[YPONotificationRequest alloc] init];
    request.function = @"notification.list";
    return request;
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
