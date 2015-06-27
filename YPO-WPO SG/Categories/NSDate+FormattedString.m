//
//  NSDate+FormattedString.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NSDate+FormattedString.h"

NSString * const ISODateFormat = @"yyyy-MM-dd";
NSString * const ISODateTimeFormat = @"yyyy-MM-dd HH:mm:ss";
NSString * const DateWithWeekday = @"EEEE, dd MMMM yyyy";

@implementation NSDate (FormattedString)

- (NSString *)stringWithFormat:(NSString *)format {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    formatter.dateFormat = format;
    return [formatter stringFromDate:self];
}

+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format {
    static NSDateFormatter *formatter;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc] init];
    }
    formatter.dateFormat = format;
    return [formatter dateFromString:dateString];
}


@end
