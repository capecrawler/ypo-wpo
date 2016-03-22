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
#import "YPOAttributedLabel.h"


@interface MemberDetailsViewController()<MFMailComposeViewControllerDelegate, TTTAttributedLabelDelegate>

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *chapterLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profileView;
@property (weak, nonatomic) IBOutlet UILabel *roleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateJoinedLabel;
@property (weak, nonatomic) IBOutlet YPOAttributedLabel *mobileLabel;
@property (weak, nonatomic) IBOutlet YPOAttributedLabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *companyLabel;
@property (weak, nonatomic) IBOutlet UILabel *positionLabel;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UILabel *address2Label;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeLabel;
@property (weak, nonatomic) IBOutlet UILabel *countryLabel;
@property (weak, nonatomic) IBOutlet YPOAttributedLabel *websiteLabel;

@property (weak, nonatomic) IBOutlet UILabel *mobileTitle;
@property (weak, nonatomic) IBOutlet UILabel *emailTitle;
@property (weak, nonatomic) IBOutlet UILabel *companyTitle;
@property (weak, nonatomic) IBOutlet UILabel *positionTitle;
@property (weak, nonatomic) IBOutlet UILabel *addressTitle;
@property (weak, nonatomic) IBOutlet UILabel *address2Title;
@property (weak, nonatomic) IBOutlet UILabel *zipCodeTitle;
@property (weak, nonatomic) IBOutlet UILabel *countryTitle;
@property (weak, nonatomic) IBOutlet UILabel *websiteTitle;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *mobileTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *emailTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *companyTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *positionTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addressTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *address2TopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zipCodeTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countryTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *websiteTopConstraint;

@property (nonatomic, strong) YPOMember *member;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end


@implementation MemberDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CAShapeLayer *mask = [CAShapeLayer layer];
    CGRect imageRect = CGRectMake(0, 0, self.profileView.bounds.size.width, self.profileView.bounds.size.height);
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithOvalInRect:imageRect];
    mask.path = circlePath.CGPath;
    self.profileView.layer.mask = mask;
    
    self.mobileLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor lightGrayColor]};
    self.mobileLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.mobileLabel.delegate = self;
    
    self.emailLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor lightGrayColor]};
    self.emailLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.emailLabel.delegate = self;
    
    self.websiteLabel.activeLinkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor lightGrayColor]};
    self.websiteLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName : [UIColor darkGrayColor]};
    self.websiteLabel.delegate = self;
    
    [self fetchMemberDetails];
    [self loadData];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cancellationToken cancel];
}


- (void)loadData {
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPOMemberDetailsRequest *request = (YPOMemberDetailsRequest *)[YPOMemberDetails constructRequest:self.cancellationToken];
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
    [self.profileView sd_setImageWithURL:[NSURL URLWithString:self.member.profilePicURL] placeholderImage:[UIImage imageNamed:@"profile"]];
    
    if ([self.member.company.name isNotEmpty]) {
        self.companyLabel.text = self.member.company.name;
    }
    
    if ([self.member.company.position isNotEmpty]) {
        self.positionLabel.text = self.member.company.position;
    }
    
    if ([self.member.contactDetails.mobile isNotEmpty]) {
        self.mobileLabel.text = self.member.contactDetails.mobile;
        self.mobileTitle.hidden = NO;
        self.mobileTopConstraint.constant = 8;
        NSRange range = NSMakeRange(0, self.member.contactDetails.mobile.length);
        [self.mobileLabel addLinkToURL:[NSURL URLWithString:@"ypo://member/mobile"] withRange:range];
    } else {
        self.mobileLabel.text = @"";
        self.mobileTitle.hidden = YES;
        self.mobileTopConstraint.constant = 0;
    }
    
    
    if ([self.member.contactDetails.email isNotEmpty]) {
        self.emailLabel.text = self.member.contactDetails.email;
        self.emailTitle.hidden = NO;
        self.emailTopConstraint.constant = 8;
        NSRange range = NSMakeRange(0, self.member.contactDetails.email.length);
        [self.emailLabel addLinkToURL:[NSURL URLWithString:@"ypo://member/email"] withRange:range];
    } else {
        self.emailLabel.text = @"";
        self.emailTitle.hidden = YES;
        self.emailTopConstraint.constant = 0;
    }
    
    if ([self.member.company.name isNotEmpty]) {
        self.companyLabel.text = self.member.company.name;
        self.companyTitle.hidden = NO;
        self.companyTopConstraint.constant = 8;
    } else {
        self.companyLabel.text = @"";
        self.companyTitle.hidden = YES;
        self.companyTopConstraint.constant = 0;
    }
    
    if ([self.member.company.position isNotEmpty]) {
        self.positionLabel.text = self.member.company.position;
        self.positionTitle.hidden = NO;
        self.positionTopConstraint.constant = 8;
    } else {
        self.positionLabel.text = @"";
        self.positionTitle.hidden = YES;
        self.positionTopConstraint.constant = 0;
    }
    
    
    if ([self.member.company.country isNotEmpty]) {
        self.countryLabel.text = self.member.company.country;
        self.countryTitle.hidden = NO;
        self.countryTopConstraint.constant = 8;
    } else {
        self.countryLabel.text = @"";
        self.countryTitle.hidden = YES;
        self.countryTopConstraint.constant = 0;
    }
    
    
    if ([self.member.company.address1 isNotEmpty]) {
        self.addressLabel.text = self.member.company.address1;
        self.addressTitle.hidden = NO;
        self.addressTopConstraint.constant = 8;
    } else {
        self.addressLabel.text = @"";
        self.addressTitle.hidden = YES;
        self.addressTopConstraint.constant = 0;
    }
    
    if ([self.member.company.address2 isNotEmpty]) {
        self.address2Label.text = self.member.company.address2;
        self.address2Title.hidden = NO;
        self.address2TopConstraint.constant = 8;
    } else {
        self.address2Label.text = @"";
        self.address2Title.hidden = YES;
        self.address2TopConstraint.constant = 0;
    }
    
    if ([self.member.company.zip isNotEmpty]) {
        self.zipCodeLabel.text = self.member.company.zip;
        self.zipCodeTitle.hidden = NO;
        self.zipCodeTopConstraint.constant = 8;
    } else {
        self.zipCodeLabel.text = @"";
        self.zipCodeTitle.hidden = YES;
        self.zipCodeTopConstraint.constant = 0;
    }
    
    if ([self.member.company.website isNotEmpty]) {
        self.websiteLabel.text = self.member.company.website;
        self.websiteTitle.hidden = NO;
        self.websiteTopConstraint.constant = 8;
        NSRange range = NSMakeRange(0, self.member.company.website.length);
        [self.websiteLabel addLinkToURL:[NSURL URLWithString:@"ypo://member/website"] withRange:range];
    } else {
        self.websiteLabel.text = @"";
        self.websiteTitle.hidden = YES;
        self.websiteTopConstraint.constant = 0;
    }
    
    
    
    NSSet *roles = [self.member.role valueForKey:@"name"];
    NSString *rolesText = [[roles allObjects] componentsJoinedByString:@"\n"];
    if ([rolesText isNotEmpty]) {
        self.roleLabel.text = rolesText;
    } else {
        self.roleLabel.text = @"";
    }
    
    NSString *dateJoined = [NSString stringWithFormat:@"Joined: %@", [self.member.joinedDate stringWithFormat:@"dd MMMM YYYY"]];
    self.dateJoinedLabel.text = dateJoined;
    
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

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    NSString *absoluteUrl = url.absoluteString;
    if ([absoluteUrl isEqualToString:@"ypo://member/mobile"]) {
        [self callMobile];
    } else if ([absoluteUrl isEqualToString:@"ypo://member/email"]) {
        [self sendEmail];
    } else if ([absoluteUrl isEqualToString:@"ypo://member/website"]) {
        [self openWebsite];
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
    NSArray* words = [number componentsSeparatedByCharactersInSet :[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString* phoneNumber = [words componentsJoinedByString:@""];
    if ([UIApplication instancesRespondToSelector:@selector(canOpenURL:)]) {
        NSURL *aURL = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
        if ([[UIApplication sharedApplication] canOpenURL:aURL]) {
            [[UIApplication sharedApplication] openURL:aURL];
        }
    }
}

#pragma mark - Website

- (void)openWebsite {
    if ([self.member.company.website isNotEmpty]) {
        if ([UIApplication instancesRespondToSelector:@selector(canOpenURL:)]) {
            NSURL *aURL = [NSURL URLWithString:self.member.company.website];
            if ([[UIApplication sharedApplication] canOpenURL:aURL]) {
                [[UIApplication sharedApplication] openURL:aURL];
            }
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
