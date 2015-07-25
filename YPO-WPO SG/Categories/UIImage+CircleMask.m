//
//  UIImage+CircleMask.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "UIImage+CircleMask.h"

@implementation UIImage (CircleMask)

- (UIImage *)roundedImage {    
    CGRect imageRect = CGRectMake(0, 0, self.size.width * [UIScreen mainScreen].scale, self.size.height * [UIScreen mainScreen].scale);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0);
    
    // set up a path to mask/clip to, and draw it.
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:imageRect];
    [circlePath addClip];
    [self drawInRect:imageRect];
    
    // get a UIImage from the image context
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage;
}

@end
