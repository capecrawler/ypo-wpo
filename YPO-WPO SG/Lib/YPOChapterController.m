//
//  YPOChapterController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOChapterController.h"
#import "WYPopoverController.h"
#import "YPOChapter.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface YPOChapterController()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) WYPopoverController *popController;
@property (nonatomic, strong) NSArray *chapters;

@end


@implementation YPOChapterController

- (instancetype)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorInset = UIEdgeInsetsZero;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")){
            self.tableView.layoutMargins = UIEdgeInsetsZero;
        }
        self.tableView.tableFooterView = [UIView new];
        self.preferredContentSize = CGSizeMake(320, 88);
        self.tableView.scrollEnabled = NO;
        self.chapters = [YPOChapter MR_findAll];
    }
    return self;
}


- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view {
    [self.popController presentPopoverFromRect:rect inView:view permittedArrowDirections:(WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated:YES];
}

- (void)show {
    [self.popController presentPopoverAsDialogAnimated:YES];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.chapters.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    YPOChapter *chapter = self.chapters[indexPath.row];
    cell.textLabel.text = chapter.name;
    if (indexPath.row == self.chapters.count -1) {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, CGRectGetWidth(self.tableView.bounds));
    } else {
        cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        cell.layoutMargins = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    return cell;
}


#pragma mark - UITableViewDelegate


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self.popController dismissPopoverAnimated:YES completion:^{
        if ([self.chapterDelegate respondsToSelector:@selector(chapterController:didSelectChapter:)]) {
            [self.chapterDelegate chapterController:self didSelectChapter:self.chapters[indexPath.row]];
        }
    }];
}


#pragma mark - Properties


- (WYPopoverController *)popController {
    if (_popController == nil) {
        _popController = [[WYPopoverController alloc] initWithContentViewController:self];
        WYPopoverTheme *theme = _popController.theme;
        theme.fillTopColor = [UIColor whiteColor];
        theme.fillBottomColor = [UIColor whiteColor];
        theme.overlayColor = [UIColor colorWithWhite:0.3 alpha:0.75];
    }
    return _popController;
}



@end
