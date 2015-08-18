//
//  YPOEvent.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOEvent.h"
#import "UIColor+Hex.h"

@interface YPOEvent()

@property (nonatomic, strong) NSAttributedString *formattedDescriptionAttributedString;

@end


@implementation YPOEvent

@dynamic eventID;
@dynamic url;
@dynamic thumbUrl;
@dynamic type;
@dynamic title;
@dynamic startDate;
@dynamic endDate;
@dynamic location;
@dynamic latitude;
@dynamic longitude;
@dynamic capacityLimit;
@dynamic parking;
@dynamic registrationStatus;
@dynamic resource;
@dynamic eventDescription;

@synthesize formattedDescriptionAttributedString;

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
    
    id venue     = dictionary[@"venue"];
    if (venue && [venue isKindOfClass:[NSDictionary class]]) {
        self.location       = venue[@"location"];
        self.latitude       = venue[@"latitude"];
        self.longitude      = venue[@"longitude"];
        self.capacityLimit  = venue[@"capacity_limit"];
        self.parking        = venue[@"parking"];
    }
    self.registrationStatus = dictionary[@"registration_status"];
    self.resource           = dictionary[@"resource"];
    self.eventDescription   = dictionary[@"description"];
    
    
}

- (NSString *)startMonth {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    return [formatter stringFromDate:self.startDate];
}

- (NSAttributedString *)formattedDescriptionWithFont:(UIFont *)font textColor:(UIColor *)textColor{
    if (self.formattedDescriptionAttributedString == nil) {
        NSString *styleFont = [NSString stringWithFormat:@"<style>body{font-family: '%@';font-size: %fpx; color:%@} p{display:inline;}</style>", font.fontName, font.pointSize, textColor.hexString];
        NSString *htmlString = [self.eventDescription stringByAppendingString:styleFont];
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        self.formattedDescriptionAttributedString = attributedString;
    }
    return self.formattedDescriptionAttributedString;
}

+ (YPOHTTPRequest *)constructRequest {
    YPOEventRequest *request = [[YPOEventRequest alloc] init];
    request.function = @"events.list";
    return request;
}

+ (void)purgeData {
    NSDate *finishedEventDate = [NSDate new];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"endDate < %@", finishedEventDate];
    NSArray *oldEvents = [YPOEvent MR_findAllWithPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    for (YPOEvent *event in oldEvents) {
        [event MR_deleteEntityInContext:[NSManagedObjectContext MR_defaultContext]];
    }
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
