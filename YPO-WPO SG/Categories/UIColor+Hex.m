//
//  UIColor+Hex.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "UIColor+Hex.h"

@implementation UIColor (Hex)

- (NSString *)hexString{
    const CGFloat *components = CGColorGetComponents(self.CGColor);
    
    CGFloat r = components[0];
    CGFloat g = components[1];
    CGFloat b = components[2];
    
    return [NSString stringWithFormat:@"#%02lX%02lX%02lX",
            lroundf(r * 255),
            lroundf(g * 255),
            lroundf(b * 255)];
}

@end
