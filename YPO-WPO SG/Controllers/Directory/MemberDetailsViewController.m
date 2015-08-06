//
//  MemberDetailsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MemberDetailsViewController.h"
#import "YPOMember.h"
#import "YPOMemberDetails.h"
#import "YPOCompany.h"
#import "YPOContactDetails.h"
#import "YPOImageCache.h"
#import "UIImage+CircleMask.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <MessageUI/MFMailComposeViewController.h>


@interface MemberDetailsViewController()<MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UIButton *videoMessageButton;
@property (weak, nonatomic) IBOutlet UIButton *followButton;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UIButton *emailButton;
@property (weak, nonatomic) IBOutlet UIButton *mobileButton;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIButton *businessButton;
@property (nonatomic, strong) YPOMember *member;

@end


@implementation MemberDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.emailButton.enabled = NO;
    self.mobileButton.enabled = NO;
    self.homeButton.enabled = NO;
    self.businessButton.enabled = NO;
    self.companyLabel.text = @"N/A";
    self.positionLabel.text = @"N/A";
    
    self.videoMessageButton.backgroundColor = [UIColor whiteColor];
    self.videoMessageButton.layer.cornerRadius = 4;
    self.videoMessageButton.layer.borderWidth = 1;
    self.videoMessageButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.followButton.backgroundColor = [UIColor whiteColor];
    self.followButton.layer.cornerRadius = 4;
    self.followButton.layer.borderWidth = 1;
    self.followButton.layer.borderColor = [UIColor lightGrayColor].CGColor;
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    CGRect imageRect = CGRectMake(0, 0, self.profileView.bounds.size.width, self.profileView.bounds.size.height);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:imageRect];
    mask.path = circlePath.CGPath;
    self.profileView.layer.mask = mask;
    
    [self fetchMemberDetails];
    [self loadData];
    
    [self.emailButton addTarget:self action:@selector(sendEmail) forControlEvents:UIControlEventTouchUpInside];
    [self.mobileButton addTarget:self action:@selector(callMobile) forControlEvents:UIControlEventTouchUpInside];
    [self.homeButton addTarget:self action:@selector(callHome) forControlEvents:UIControlEventTouchUpInside];
    [self.businessButton addTarget:self action:@selector(callBusiness) forControlEvents:UIControlEventTouchUpInside];
}


- (void)loadData {
    YPOMemberDetailsRequest *request = (YPOMemberDetailsRequest *)[YPOMemberDetails constructRequest];
    request.memberID = self.memberID;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
    [self fetchMemberDetails];
    } failure:nil];
}


- (void)fetchMemberDetails{
    if (self.member == nil) {
        self.nameLabel.text = @" ";
        self.chapterLabel.text = @" ";
        return;
    }
    self.nameLabel.text = self.member.name;
    self.chapterLabel.text = self.member.chapter;
    [self.profileView sd_setImageWithURL:[NSURL URLWithString:self.member.profilePicURL]];
    
    if ([self.member.company.name isNotEmpty]) {
        self.companyLabel.text = self.member.company.name;
    }
    
    if ([self.member.company.position isNotEmpty]) {
        self.positionLabel.text = self.member.company.position;
    }
    
    if ([self.member.contactDetails.email isNotEmpty]) {
        [self.emailButton setTitle:self.member.contactDetails.email forState:UIControlStateNormal];
        self.emailButton.enabled = YES;
    }
    
    if ([self.member.contactDetails.mobile isNotEmpty]) {
        [self.mobileButton setTitle:self.member.contactDetails.mobile forState:UIControlStateNormal];
        self.mobileButton.enabled = YES;
    }
    
    if ([self.member.contactDetails.home isNotEmpty]) {
        [self.homeButton setTitle:self.member.contactDetails.home forState:UIControlStateNormal];
        self.homeButton.enabled = YES;
    }
    
    if ([self.member.contactDetails.business isNotEmpty]) {
        [self.businessButton setTitle:self.member.contactDetails.business forState:UIControlStateNormal];
        self.businessButton.enabled = YES;
    }
}


- (void) callMobile {
    NSString *mobile = self.member.contactDetails.mobile;
    if ([mobile isNotEmpty]) {
        [self callPhoneNumber:mobile];
    }
}

- (void) callHome {
    NSString *home = self.member.contactDetails.home;
    if ([home isNotEmpty]) {
        [self callPhoneNumber:home];
    }
}

- (void) callBusiness {
    NSString *business = self.member.contactDetails.business;
    if ([business isNotEmpty]) {
        [self callPhoneNumber:business];
    }
}



#pragma mark - Email

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendEmail {
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeController = [[MFMailComposeViewController alloc] init];
        [[composeController navigationBar] setTintColor: self.navigationController.navigationBar.barTintColor];
        composeController.mailComposeDelegate = self;
        [composeController setToRecipients:@[self.member.contactDetails.email]];
        [self presentViewController:composeController animated:YES completion:nil];
    }
}


#pragma mark - Call

- (void)callPhoneNumber: (NSString *)number {
    if ([UIApplication instancesRespondToSelector:@selector(canOpenURL:)]) {
        NSURL *aURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", number]];
        if ([[UIApplication sharedApplication] canOpenURL:aURL]) {
            [[UIApplication sharedApplication] openURL:aURL];
        }
    }
}


- (YPOMember *)member {
    if (_member == nil) {
        _member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:self.memberID inContext:[NSManagedObjectContext MR_defaultContext]];
    }
    return _member;
}


@end
