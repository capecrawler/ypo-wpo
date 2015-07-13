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
    __weak UIImageView *weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *circleImage = [image roundedImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf)return;
            [super setImage:circleImage];
            [self setNeedsLayout];
        });
    });
}

@end
