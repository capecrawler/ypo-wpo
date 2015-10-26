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
#import "EventDetailsView.h"
#import "EventDetailsTableViewCell.h"
#import "UIColor+Hex.h"

typedef NS_ENUM(NSInteger, EventDetailsItemType) {
    EventDetailsItemTypeResource = 0,
    EventDetailsItemTypeDate,
    EventDetailsItemTypeLocation,
    EventDetailsItemTypeVenue,
    EventDetailsItemTypeCapacity,
    EventDetailsItemTypeParking,
    EventDetailsItemTypeRegistration,
    EventDetailsItemTypeInvitees,
    EventDetailsItemTypeDayChair,
    EventDetailsItemTypeRSVP,
    EventDetailsItemTypeCancellation
};


@interface EventDetailsItem : NSObject

@property (nonatomic, strong) NSString *imageName;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) NSInteger type;

@end

@implementation EventDetailsItem
@end


@interface EventDetailsViewController ()<MFMailComposeViewControllerDelegate>

@property (nonatomic, strong) EventDetailsView *eventDetailsView;
@property (nonatomic, strong) NSMutableArray *eventItems;
@property (nonatomic, strong) YPOEvent *event;

@end

@implementation EventDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tableView registerNib:[UINib nibWithNibName:@"EventDetailsTableViewCell" bundle:nil]
         forCellReuseIdentifier:@"EventDetailsTableViewCellID"];
    self.tableView.separatorColor = [UIColor clearColor];
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
    
    [self.eventDetailsView.coverView sd_setImageWithURL:[NSURL URLWithString:self.event.thumbUrl]];
    self.eventDetailsView.titleLabel.text = self.event.title;
    self.eventDetailsView.eventTypeLabel.text = self.event.type;
    self.eventDetailsView.descriptionLabel.attributedText = [self formattedString:self.event.eventDescription
                                                                             font:self.eventDetailsView.descriptionLabel.font
                                                                        textColor:self.eventDetailsView.descriptionLabel.textColor];
    
    [self.eventDetailsView setNeedsLayout];
    [self.eventDetailsView layoutIfNeeded];
    CGFloat height = [self.eventDetailsView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    CGRect headerFrame = self.eventDetailsView.frame;
    headerFrame.size.height = height;
    self.eventDetailsView.frame = headerFrame;
    self.tableView.tableHeaderView = self.eventDetailsView;
    
    NSMutableArray *eventItems = [[NSMutableArray alloc] init];
    if ([self.event.resource isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-resource";
        item.value = self.event.resource;
        item.type = EventDetailsItemTypeResource;
        [eventItems addObject:item];
    }

    if (self.event.endDate != nil) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"EEEE, MMM d 'at' hh:mm aa";
        NSString *dateString = [NSString stringWithFormat:@"%@ - %@",
                                [formatter stringFromDate:self.event.startDate],
                                [formatter stringFromDate:self.event.endDate]];
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-time";
        item.value = dateString;
        item.type = EventDetailsItemTypeDate;
        [eventItems addObject:item];
    }
    
    if ([self.event.location isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-location";
        item.value = self.event.location;
        item.type = EventDetailsItemTypeLocation;
        [eventItems addObject:item];
    }

    if ([self.event.capacityLimit isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-capacity";
        item.value = self.event.capacityLimit;
        item.type = EventDetailsItemTypeCapacity;
        [eventItems addObject:item];
    }
    
    if ([self.event.parking isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-parking";
        item.value = self.event.parking;
        item.type = EventDetailsItemTypeParking;
        [eventItems addObject:item];
    }
    
    if ([self.event.registrationStatus isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-registration";
        item.value = self.event.registrationStatus;
        item.type = EventDetailsItemTypeRegistration;
        [eventItems addObject:item];
    }
    
    if ([self.event.inviteeType isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-invitees";
        item.value = self.event.inviteeType;
        item.type = EventDetailsItemTypeInvitees;
        [eventItems addObject:item];
    }
    
    if ([self.event.dayChairName isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-daychair";
        item.value = self.event.dayChairName;
        item.type = EventDetailsItemTypeDayChair;
        [eventItems addObject:item];
    }
    
    if ([self.event.rsvpName isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-rsvp";
        item.value = self.event.rsvpName;
        item.type = EventDetailsItemTypeRSVP;
        [eventItems addObject:item];
    }
    
    if ([self.event.rsvpEmail isNotEmpty]) {
        UIBarButtonItem *rsvpItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"ic-rsvp"] style:UIBarButtonItemStylePlain target:self action:@selector(sendRSVP)];
        self.navigationItem.rightBarButtonItem = rsvpItem;
    }
    
    if ([self.event.cancellationPolicy isNotEmpty]) {
        EventDetailsItem *item = [[EventDetailsItem alloc] init];
        item.imageName = @"ic-cancellation";
        item.value = self.event.cancellationPolicy;
        item.type = EventDetailsItemTypeCancellation;
        [eventItems addObject:item];
    }
    
    self.eventItems = eventItems;
    [self.tableView reloadData];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.eventItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"EventDetailsTableViewCellID";
    EventDetailsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

- (void)configureCell:(EventDetailsTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    EventDetailsItem *item = self.eventItems[indexPath.row];
    cell.iconView.image = [[UIImage imageNamed:item.imageName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    if (item.type == EventDetailsItemTypeResource ||
        item.type == EventDetailsItemTypeCancellation) {
        cell.detailLabel.attributedText = [self formattedString:item.value
                                                           font:cell.detailLabel.font
                                                      textColor:cell.detailLabel.textColor];
    } else {
        cell.detailLabel.text = item.value;
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    EventDetailsItem *item = self.eventItems[indexPath.row];
    if (item.type == EventDetailsItemTypeRSVP) {
        if ([self.event.rsvpEmail isNotEmpty]) {
            [self sendRSVP];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *const cellID = @"EventDetailsTableViewCellID";
    static EventDetailsTableViewCell *cell;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cell = [self.tableView dequeueReusableCellWithIdentifier:cellID];
    });
    [self configureCell:cell atIndexPath:indexPath];
    return [self calculateHeightForConfiguredSizingCell:cell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
    sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.frame), CGRectGetHeight(sizingCell.bounds));
    [sizingCell setNeedsLayout];
    [sizingCell layoutIfNeeded];
    
    CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (NSAttributedString *)formattedString:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor{
    NSString *styleFont = [NSString stringWithFormat:@"<style>body, p, li, span {font-family: '%@';font-size: %fpx; color:%@} p{display:inline;}</style>",
                           font.fontName,
                           font.pointSize,
                           textColor.hexValue];
    NSString *htmlString = [text stringByAppendingString:styleFont];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithData:
                                                   [htmlString dataUsingEncoding:NSUTF8StringEncoding]
                                                                                          options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
                                                                               documentAttributes:nil
                                                                                            error:nil];
    return attributedString;
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


- (EventDetailsView *)eventDetailsView {
    if (_eventDetailsView == nil) {
        _eventDetailsView = [[[NSBundle mainBundle] loadNibNamed:@"EventDetailsView" owner:self options:nil]firstObject];
        _eventDetailsView.frame = CGRectMake(0, 0, self.tableView.bounds.size.width, 0);
    }
    return _eventDetailsView;
}


@end
