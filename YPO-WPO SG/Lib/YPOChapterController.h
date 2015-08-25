//
//  YPOChapterController.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YPOChapterController;
@class YPOChapter;

@protocol YPOChapterControllerDelegate <NSObject>
- (void)chapterController:(YPOChapterController *)controller didSelectChapter:(YPOChapter *)chapter;
@end

@interface YPOChapterController : UITableViewController

@property (nonatomic, weak)id<YPOChapterControllerDelegate> chapterDelegate;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view;
- (void)show;

@end
