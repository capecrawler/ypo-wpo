//
//  EventDetailsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/13/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventDetailsViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "YPOEvent.h"

@interface EventDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.event.thumbUrl]];
    self.titleLabel.text = self.event.title;
    self.typeLabel.text = self.event.type;
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"EEEE, MMM d 'at' hh:mm aa";
    NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.event.startDate], [formatter stringFromDate:self.event.endDate]];
    self.dateLabel.text = dateString;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
