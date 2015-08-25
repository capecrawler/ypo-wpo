//
//  YPODateController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 8/23/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPODateController.h"
#import <WYPopoverController/WYPopoverController.h>

@interface YPODateController()

@property (nonatomic, strong) WYPopoverController *popController;
@property (nonatomic, strong) NSDate *selectedDate;
@property (nonatomic, strong) UIDatePicker *datePicker;

@end


@implementation YPODateController

- (instancetype)initWithSelectedDate:(NSDate *)date {
    self = [super init];
    if (self) {
        self.selectedDate = date;
        self.modalInPopover = NO;
        self.title = @"Select Date";
        self.preferredContentSize = CGSizeMake(self.view.bounds.size.width, self.datePicker.bounds.size.height + 44);
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.datePicker];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    cancel.tintColor = [UIColor darkGrayColor];
    self.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(apply)];
    done.tintColor = [UIColor darkGrayColor];
    self.navigationItem.rightBarButtonItem = done;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.datePicker.date = self.selectedDate;
    self.navigationController.navigationBar.barTintColor = [UIColor grayColor];
}


- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view {
    [self.popController presentPopoverFromRect:rect inView:view permittedArrowDirections:(WYPopoverArrowDirectionUp | WYPopoverArrowDirectionDown) animated:YES];
}


- (void)show {
    [self.popController presentPopoverAsDialogAnimated:YES options:WYPopoverAnimationOptionFadeWithScale];
}


- (void)dismiss {
    [self.popController dismissPopoverAnimated:YES];
}


- (void)apply {
    [self.popController dismissPopoverAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(dateController:dateSelected:)]) {
            [self.delegate dateController:self dateSelected:self.datePicker.date];
        }
    }];
}


#pragma mark - Properties

- (WYPopoverController *)popController {
    if (_popController == nil) {
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self];
        navigationController.navigationBar.barStyle = UIBarStyleBlack;
        [navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor darkGrayColor],
                                                               NSFontAttributeName: [UIFont fontWithName:@"Georgia-Bold" size:18]}];
        _popController = [[WYPopoverController alloc] initWithContentViewController:navigationController];
    }
    return _popController;
}


- (UIDatePicker *)datePicker {
    if (_datePicker == nil) {
        _datePicker = [[UIDatePicker alloc] initWithFrame:CGRectMake(-10, 0, self.view.bounds.size.width, 162)];
        _datePicker.backgroundColor = [UIColor whiteColor];
        _datePicker.datePickerMode = UIDatePickerModeDate;
    }
    return _datePicker;
}

@end
