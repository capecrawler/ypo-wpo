//
//  UIImageView+YPOCache.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "UIImageView+YPOCache.h"
#import "UIImage+CircleMask.h"
#import "objc/runtime.h"
#import "YPOImageCache.h"
#import <SDWebImage/UIView+WebCacheOperation.h>
#import <SDWebImage/SDWebImageDownloader.h>
#import <SDWebImage/SDWebImageDownloaderOperation.h>
#import <Bolts/Bolts.h>

static char imageURLKey;

@implementation UIImageView (YPOCache)

- (void)ypo_setImageWithURL:(NSURL *)url {
    [self ypo_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:nil];
}

- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder {
    [self ypo_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:nil];
}

- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options {
    [self ypo_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:nil];
}

- (void)ypo_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock {
    [self ypo_setImageWithURL:url placeholderImage:nil options:0 progress:nil completed:completedBlock];
}

- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock {
    [self ypo_setImageWithURL:url placeholderImage:placeholder options:0 progress:nil completed:completedBlock];
}

- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock {
    [self ypo_setImageWithURL:url placeholderImage:placeholder options:options progress:nil completed:completedBlock];
}

- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock {
    [self ypo_cancelCurrentImageLoad];
    objc_setAssociatedObject(self, &imageURLKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!(options & SDWebImageDelayPlaceholder)) {
        dispatch_main_async_safe(^{
            self.image = placeholder;
        });
    }
    
    if (url) {
        __weak UIImageView *wself = self;
        NSString *key = url.absoluteString;
        [[YPOImageCache sharedImageCache] queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
            if (image == nil) {
                SDWebImageDownloaderOperation * operation = [SDWebImageDownloader.sharedDownloader downloadImageWithURL:url options:0 progress:nil completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                    if (!wself) return;
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                        UIImage *roundedImage = [image roundedImage];
                        if (!operation.isCancelled) {
                            [[YPOImageCache sharedImageCache] storeImage:roundedImage forKey:key];
                            if (!operation.isCancelled) {
                                dispatch_main_sync_safe(^{
                                    if (!wself) return;
                                    if (roundedImage) {
                                        wself.image = roundedImage;
                                        [wself setNeedsLayout];
                                    } else {
                                        if ((options & SDWebImageDelayPlaceholder)) {
                                            wself.image = placeholder;
                                            [wself setNeedsLayout];
                                        }
                                    }
                                    if (completedBlock) {
                                        completedBlock(roundedImage, nil, cacheType, url);
                                    }
                                });
                            }
                        }
                    });
                }];
                [self sd_setImageLoadOperation:operation forKey:@"UIImageViewImageLoad"];
            } else {
                if (!wself) return;
                dispatch_main_sync_safe(^{
                    if (!wself) return;
                    if (image) {
                        wself.image = image;
                        [wself setNeedsLayout];
                    } else {
                        if ((options & SDWebImageDelayPlaceholder)) {
                            wself.image = placeholder;
                            [wself setNeedsLayout];
                        }
                    }
                    if (completedBlock) {
                        completedBlock(image, nil, cacheType, url);
                    }
                });
            }
        }];
    } else {
        dispatch_main_async_safe(^{
            NSError *error = [NSError errorWithDomain:@"SDWebImageErrorDomain" code:-1 userInfo:@{NSLocalizedDescriptionKey : @"Trying to load a nil url"}];
            if (completedBlock) {
                completedBlock(nil, error, SDImageCacheTypeNone, url);
            }
        });
    }
}

- (void)ypo_cancelCurrentImageLoad {
    [self sd_cancelImageLoadOperationWithKey:@"UIImageViewImageLoad"];
}


@end
