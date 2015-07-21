//
//  MemberTableViewCell.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MemberTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YPOMember.h"
#import "NSDate+FormattedString.h"
#import "UIImage+CircleMask.h"
#import "YPOImageCache.h"
#import <Bolts/Bolts.h>

@interface ImageCancellationToken : NSObject
@property (nonatomic, assign, getter=isCancelled) BOOL cancel;
@end


@implementation ImageCancellationToken
@end


@interface MemberTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *profileImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *membershipLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateJoinedLabel;
@property (strong, nonatomic) id <SDWebImageOperation> operation;
@property (nonatomic, strong) ImageCancellationToken *token;

@end

@implementation MemberTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    // Hack to remove autolayout warning prior to iOS 8.0 when subviews with fixed width using autolayout
    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.showJoinedDate = YES;
    self.profileImageView.layer.contentsScale = [UIScreen mainScreen].scale;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
}

- (void)setMember:(YPOMember *)member {
    _member = member;
    self.nameLabel.text = self.member.name;
    self.membershipLabel.text = self.member.chapter;
    [self loadProfileImageView];
    if (self.showJoinedDate) {
        self.dateJoinedLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Date Joined: %@", @"Date joined text"), [self.member.joinedDate stringWithFormat:@"dd MMMM yyyy"]];
    } else {
        self.dateJoinedLabel.text = @"";
    }
}

- (void)loadProfileImageView {
    [self.operation cancel];
    self.profileImageView.image = nil;
    self.token.cancel = YES;
    self.token = [[ImageCancellationToken alloc]init];
    
    NSString *imageURL = [self.member.profilePicURL copy];
    __weak UIImageView *wselfImage = self.profileImageView;
    [[YPOImageCache sharedImageCache] queryDiskCacheForKey:self.member.profilePicURL done:^(UIImage *image, SDImageCacheType cacheType) {
        if (image == nil) {
            self.operation = [SDWebImageDownloader.sharedDownloader downloadImageWithURL:[NSURL URLWithString: self.member.profilePicURL]
                                                                                 options:0
                                                                                progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                                                    // progression tracking code
                                                                                } completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                                                    NSLog(@"image downloaded");
                                                                                    if (!wselfImage)return;
                                                                                    if (image && finished) {
                                                                                        [self setImage:image toImageView:wselfImage withURL:imageURL token:self.token];
                                                                                    }
                                                                                }];
        } else {
            self.profileImageView.image = image;
        }
    }];
}


- (void)setImage:(UIImage *)image toImageView:(UIImageView *)imageView withURL:(NSString *)url token:(ImageCancellationToken *)token {
    __strong UIImageView *sImageView = imageView;
    [[self roundedImage:image withURL:url cancellationToken:token] continueWithBlock:^id(BFTask *task) {
        if (!token.isCancelled) {
            if (sImageView != nil && [url isEqualToString:self.member.profilePicURL]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    sImageView.image = task.result;                    
                });
            }
        }
        return nil;
    }];
}


- (BFTask *)roundedImage:(UIImage *)image withURL:(NSString *)url cancellationToken:(ImageCancellationToken *)token {
    BFTaskCompletionSource *task = [BFTaskCompletionSource taskCompletionSource];
        NSLog(@"start rounded image");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *roundedImage = [image roundedImage];
        NSLog(@"done rounded image");
        [[YPOImageCache sharedImageCache] storeImage:roundedImage forKey:url];
        [task setResult:roundedImage];
    });
    return task.task;
}


@end

