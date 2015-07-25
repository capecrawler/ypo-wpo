//
//  UIImageView+YPOCache.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SDWebImage/SDWebImageCompat.h>
#import <SDWebImage/SDWebImageManager.h>

@interface UIImageView (YPOCache)
- (void)ypo_setImageWithURL:(NSURL *)url;
- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder;
- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options;
- (void)ypo_setImageWithURL:(NSURL *)url completed:(SDWebImageCompletionBlock)completedBlock;
- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder completed:(SDWebImageCompletionBlock)completedBlock;
- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options completed:(SDWebImageCompletionBlock)completedBlock;
- (void)ypo_setImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletionBlock)completedBlock;
- (void)ypo_cancelCurrentImageLoad;

@end
