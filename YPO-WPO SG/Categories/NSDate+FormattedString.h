//
//  NSDate+FormattedString.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const ISODateFormat;
extern NSString * const ISODateTimeFormat;
extern NSString * const DateWithWeekday;

@interface NSDate (FormattedString)

- (NSString *)stringWithFormat:(NSString *)format;
+ (NSDate *)dateFromString:(NSString *)dateString format:(NSString *)format;

@end
