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
#import "YPOAPIClient.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface EventDetailsViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;


@property (weak, nonatomic) IBOutlet UILabel *resourceLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *resourceTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icResourceHeightConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icTimeHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *dateTopConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icLocationHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *locationTopConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *capacityTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *capacityLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icCapacityHeightConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icParkingHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *parkingLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *parkingTopConstraint;



@property (weak, nonatomic) IBOutlet NSLayoutConstraint *registrationTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *registrationLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icRegistrationHeightConstraint;


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inviteesTopConstraint;

@property (weak, nonatomic) IBOutlet UILabel *inviteesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icInviteesHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (nonatomic, strong) YPOEvent *event;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self fetchEventDetails];
    [self loadEventDetails];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadEventDetails {
    
    NSDictionary *parameters = @{@"func" : @"event.details",
                                 @"event_id" : self.eventID};
    [[YPOAPIClient sharedClient] GET:YPOAPIPathPrefix parameters:parameters success:^(NSURLSessionDataTask *task, id responseObject) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSDictionary *data = responseObject[@"data"];
            YPOEvent *event = [YPOEvent MR_findFirstByAttribute:@"eventID" withValue:data[@"event_id"] inContext:localContext];
            if (event == nil) {
                event = [YPOEvent MR_createEntityInContext:localContext];
            }
            [event parseDictionary:data];
        }];
        [self fetchEventDetails];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeBlack];
    }];
    
}


- (void)fetchEventDetails{
    
    if (self.event == nil) {
        self.titleLabel.text = @"";
        self.typeLabel.text = @"";
    } else {
        [self.coverImageView sd_setImageWithURL:[NSURL URLWithString:self.event.thumbUrl]];
        self.titleLabel.text = self.event.title;
        self.typeLabel.text = self.event.type;
    }
    
    if ([self.event.resource isNotEmpty]) {
        self.icResourceHeightConstraint.constant = 24;
        self.resourceTopConstraint.constant = 16;
        self.resourceLabel.text = self.event.resource;
    } else {
        self.icResourceHeightConstraint.constant = 0;
        self.resourceTopConstraint.constant = 0;
        self.resourceLabel.text = @"";
    }
    
    if (self.event.endDate != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE, MMM d 'at' hh:mm aa";
        NSString *dateString = [NSString stringWithFormat:@"%@ - %@", [formatter stringFromDate:self.event.startDate], [formatter stringFromDate:self.event.endDate]];
        self.dateLabel.text = dateString;
        self.icTimeHeightConstraint.constant = 24;
    } else {
        self.dateLabel.text = @"";
        self.icTimeHeightConstraint.constant = 0;
    }
    
    
    if ([self.event.location isNotEmpty]) {
        self.icLocationHeightConstraint.constant = 24;
        self.locationTopConstraint.constant = 16;
        self.locationLabel.text = self.event.location;
    } else {
        self.icLocationHeightConstraint.constant = 0;
        self.locationTopConstraint.constant = 0;
        self.locationLabel.text = @"";
    }
    
    
    if ([self.event.capacityLimit isNotEmpty]) {
        self.icCapacityHeightConstraint.constant = 24;
        self.capacityTopConstraint.constant = 16;
        self.capacityLabel.text = self.event.capacityLimit;
    } else {
        self.icCapacityHeightConstraint.constant = 0;
        self.capacityTopConstraint.constant = 0;
        self.capacityLabel.text = self.event.capacityLimit;
    }
    
    
    if ([self.event.parking isNotEmpty]) {
        self.icParkingHeightConstraint.constant = 24;
        self.parkingTopConstraint.constant = 16;
        self.parkingLabel.text = self.event.parking;
    } else {
        self.icParkingHeightConstraint.constant = 0;
        self.parkingTopConstraint.constant = 0;
        self.parkingLabel.text = @"";
    }
    
    
    if ([self.event.registrationStatus isNotEmpty]) {
        self.icRegistrationHeightConstraint.constant = 24;
        self.registrationTopConstraint.constant = 16;
        self.registrationLabel.text = self.event.registrationStatus;
    } else {
        self.icRegistrationHeightConstraint.constant = 0;
        self.registrationTopConstraint.constant = 0;
        self.registrationLabel.text = self.event.registrationStatus;
    }
 
    if ([self.event.eventDescription isNotEmpty]) {
        self.descriptionLabel.attributedText = [self.event formattedDescriptionWithFont:self.descriptionLabel.font textColor:self.descriptionLabel.textColor];
    } else {
        self.descriptionLabel.text = nil;
        self.descriptionLabel.attributedText = nil;
    }

}


#pragma mark - Properties

- (YPOEvent *)event {
    if (_event == nil) {
        _event = [YPOEvent MR_findFirstByAttribute:@"eventID" withValue:self.eventID inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return _event;
}


@end
