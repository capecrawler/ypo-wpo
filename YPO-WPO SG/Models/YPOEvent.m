//
//  YPOEvent.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOEvent.h"


@implementation YPOEvent

@dynamic eventID;
@dynamic url;
@dynamic thumbUrl;
@dynamic type;
@dynamic title;
@dynamic startDate;
@dynamic endDate;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.eventID            = dictionary[@"event_id"];
    self.url                = dictionary[@"url"];
    self.thumbUrl           = dictionary[@"thumb_url"];
    self.type               = dictionary[@"type"];
    self.title              = dictionary[@"title"];
    NSString *startDate     = dictionary[@"start_date"];
    self.startDate          = [NSDate dateFromInternetDateTimeString:startDate formatHint:DateFormatHintRFC3339];
    NSString *endDate       = dictionary[@"end_date"];
    self.endDate            = [NSDate dateFromInternetDateTimeString:endDate formatHint:DateFormatHintRFC3339];
}

- (NSString *)startMonth {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    return [formatter stringFromDate:self.startDate];
}

+ (YPOHTTPRequest *)constructRequest {
    YPOEventRequest *request = [[YPOEventRequest alloc] init];
    request.function = @"events.list";
    return request;
}


@end


@implementation YPOEventRequest

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
                YPOEvent * event = [YPOEvent MR_findFirstByAttribute:@"eventID" withValue:raw[@"event_id"] inContext:localContext];
                if (event == nil) {
                    event = [YPOEvent MR_createEntityInContext:localContext];
                }
                [event parseDictionary:raw];
            }
        }];
    }
}


@end
