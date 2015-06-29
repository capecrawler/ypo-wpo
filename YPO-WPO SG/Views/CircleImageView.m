//
//  CircleImageView.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "CircleImageView.h"
#import "UIImage+CircleMask.h"

@implementation CircleImageView

- (void) setImage:(UIImage *)image {
    UIImage *circleImage = [image roundedImage];
    [super setImage:circleImage];
}

@end
