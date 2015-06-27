//
//  CircleImageView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "CircleImageView.h"

@implementation CircleImageView

/*
- (void)layoutSubviews {
    [super layoutSubviews];
    CAShapeLayer *circle = [CAShapeLayer layer];
    // Make a circular shape
    CGRect insetRect = CGRectInset(self.bounds, 1, 1);    
    UIBezierPath *circularPath=[UIBezierPath bezierPathWithRoundedRect:insetRect cornerRadius:MAX(self.frame.size.width, self.frame.size.height)];
    
    circle.path = circularPath.CGPath;
    
    // Configure the apperence of the circle
    circle.fillColor = [UIColor blackColor].CGColor;
    circle.strokeColor = [UIColor blackColor].CGColor;
    circle.lineWidth = 0;
    
    self.layer.mask=circle;
    
}

*/


- (void) setImage:(UIImage *)image {
    UIImage *circleImage = [self maskedAvatarFromImage:image];
    [super setImage:circleImage];
}

- (UIImage *)maskedAvatarFromImage:(UIImage *)image {
    
    // set up the drawing context
    CGRect imageRect = CGRectMake(0, 0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0);
    
    // set up a path to mask/clip to, and draw it.
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:imageRect];
    [circlePath addClip];
    [image drawInRect:imageRect];
    
    // get a UIImage from the image context
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return maskedImage;
}


@end
