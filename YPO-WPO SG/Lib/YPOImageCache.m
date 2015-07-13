//
//  YPOImageCache.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOImageCache.h"

@implementation YPOImageCache

+ (instancetype)sharedImageCache {
    static YPOImageCache *imageCache = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        imageCache = [[YPOImageCache alloc] initWithNamespace:@"com.raketeers.ypo.image"];
    });
    return imageCache;
}


@end
