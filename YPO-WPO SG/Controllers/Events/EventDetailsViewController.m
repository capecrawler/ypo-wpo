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
#import <MessageUI/MFMailComposeViewController.h>
#import "YPOAttributedLabel.h"

@interface EventDetailsViewController ()<MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate>

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


@property (weak, nonatomic) IBOutlet YPOAttributedLabel *rsvpLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rsvpTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *icRSVPHeightConstraint;


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
        self.resourceLabel.attributedText = [self.event formattedResourceWithFont:self.resourceLabel.font textColor:self.resourceLabel.textColor];
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
    
    
    if ([self.event.inviteeType isNotEmpty]) {
        self.inviteesLabel.text = self.event.inviteeType;
        self.icInviteesHeightConstraint.constant = 24;
        self.inviteesTopConstraint.constant = 16;
    } else {
        self.inviteesLabel.text = @"";
        self.icInviteesHeightConstraint.constant = 0;
        self.inviteesTopConstraint.constant = 0;
    }
    
    
    if ([self.event.rsvpName isNotEmpty]) {
        self.rsvpLabel.text = self.event.rsvpName;
        self.icRSVPHeightConstraint.constant = 24;
        self.rsvpTopConstraint.constant = 16;
        if ([self.event.rsvpEmail isNotEmpty]) {
            self.rsvpLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor lightGrayColor]};
            self.rsvpLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor darkGrayColor]};
            self.rsvpLabel.delegate = self;
            
            NSRange range = NSMakeRange(0, self.event.rsvpName.length);
            [self.rsvpLabel addLinkToURL:[NSURL URLWithString:@"ypo://event/rsvp"] withRange:range];
        }
    } else {
        self.rsvpLabel.text = @"";
        self.icRSVPHeightConstraint.constant = 0;
        self.rsvpTopConstraint.constant = 0;
    }
    
    if ([self.event.rsvpEmail isNotEmpty]) {
        UIBarButtonItem *rsvpItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-rsvp"] style:UIBarButtonItemStylePlain target:self action:@selector(sendRSVP)];
        self.navigationItem.rightBarButtonItem = rsvpItem;
    }
}


#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *absoluteUrl = url.absoluteString;
    if ([absoluteUrl isEqualToString:@"ypo://event/rsvp"]) {
        [self sendRSVP];
    }
}



#pragma mark - Mail compose methods

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)sendRSVP{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
        [[composeController navigationBar] setTintColor: [UIColor whiteColor]];
        composeController.mailComposeDelegate = self;
        
        NSString *subject = [NSString stringWithFormat: NSLocalizedString(@"RSVP: %@", nil), self.event.title];
        
        [composeController setSubject:subject];
        [composeController setMessageBody:@"" isHTML:NO];
        [composeController setToRecipients:[NSArray arrayWithObjects:self.event.rsvpEmail, nil]];
        
        [self presentViewController:composeController animated:YES completion:nil];
    } else {
        NSString *message = NSLocalizedString(@"Device is currently unable to send email. You need to set an email account first on your device.", nil);
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:NSLocalizedString(@"Can't send email", nil) message:message delegate:self cancelButtonTitle:NSLocalizedString(@"Ok", nil) otherButtonTitles: nil];
        [alertView show];
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
