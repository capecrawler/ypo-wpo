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
#import <SDWebImage/UIImageView+WebCache.h>

@interface MemberDetailsViewController()

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
    
    [self processMemberDetails];
    [self loadData];
}


- (void)loadData {
    YPOMemberDetailsRequest *request = (YPOMemberDetailsRequest *)[YPOMemberDetails constructRequest];
    request.memberID = self.member.memberID;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [self processMemberDetails];
    } failure:nil];
}



- (void)processMemberDetails {
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

@end
