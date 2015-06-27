//
//  NSString+NotEmpty.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NSString+NotEmpty.h"

@implementation NSString (NotEmpty)

- (BOOL) isNotEmpty{
    return ([self length] != 0 && [[self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] != 0);
}

@end
