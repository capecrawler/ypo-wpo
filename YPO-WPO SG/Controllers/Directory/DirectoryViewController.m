//
//  DirectoryViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "DirectoryViewController.h"


typedef NS_ENUM(NSUInteger, DirectoryMenu) {
    DirectoryMenuMembers = 0,
    DirectoryMenuNewMembers,
    DirectoryMenuManagementCommittee,
    DirectoryMenuChapterAdministrators,
    DirectoryMenuForum,
};

@interface DirectoryViewController ()

@property (nonatomic, strong) NSArray *menuOptions;

@end

@implementation DirectoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.menuOptions = @[NSLocalizedString(@"Members", nil),
                         NSLocalizedString(@"New Members", nil),
                         NSLocalizedString(@"Management Committe", nil),
                         NSLocalizedString(@"Chapter Administrators", nil),
                         NSLocalizedString(@"Forum", nil)];
    self.tableView.tableFooterView = [UIView new];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.menuOptions.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"DirectoryCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.textLabel.text = self.menuOptions[indexPath.row];
    cell.textLabel.textColor = [UIColor colorBlueTheme];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    switch (indexPath.row) {
        case DirectoryMenuMembers:
            [self performSegueWithIdentifier:@"MembersListViewController" sender:self];
            break;
        case DirectoryMenuNewMembers:
            [self performSegueWithIdentifier:@"NewMembersViewController" sender:self];
            break;
        case DirectoryMenuManagementCommittee:
            break;
        case DirectoryMenuChapterAdministrators:
            [self performSegueWithIdentifier:@"ChapterTableViewController" sender:self];
            break;
        case DirectoryMenuForum:
            [self performSegueWithIdentifier:@"ForumTableViewController" sender:self];            
            break;
        default:
            break;
    }

}

@end
