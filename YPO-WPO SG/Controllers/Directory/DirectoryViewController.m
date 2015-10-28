//
//  DirectoryViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "DirectoryViewController.h"
#import "ChapterTableViewController.h"
#import "MembersFilteredViewController.h"


typedef NS_ENUM(NSUInteger, DirectoryMenu) {
    DirectoryMenuNewMembers = 0,
    DirectoryMenuMembers,
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
    
    self.menuOptions = @[NSLocalizedString(@"New Members", nil),
                         NSLocalizedString(@"Members", nil),
                         NSLocalizedString(@"Management Committe", nil),
                         NSLocalizedString(@"Chapter Managers", nil),
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
    switch (indexPath.row) {
        case DirectoryMenuMembers:
            [self performSegueWithIdentifier:@"MembersListViewController" sender:self];
            break;
        case DirectoryMenuNewMembers:
            [self performSegueWithIdentifier:@"MembersFilteredViewController" sender:self];
            break;
        case DirectoryMenuManagementCommittee:
//            [self performSegueWithIdentifier:@"ChapterTableViewController" sender:self];
            [self performSegueWithIdentifier:@"MembersFilteredViewController" sender:self];            
            break;
        case DirectoryMenuChapterAdministrators:
//            [self performSegueWithIdentifier:@"ChapterTableViewController" sender:self];
            [self performSegueWithIdentifier:@"MembersFilteredViewController" sender:self];
            break;
        case DirectoryMenuForum:
            [self performSegueWithIdentifier:@"ForumTableViewController" sender:self];            
            break;
        default:
            break;
    }

}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    id controller = segue.destinationViewController;
    NSLog(@"class: %@", NSStringFromClass([controller class]));
    if ([controller isKindOfClass:[MembersFilteredViewController class]]) {
        MembersFilteredViewController * memberFilteredController = (MembersFilteredViewController *)controller;
        memberFilteredController.title = self.menuOptions[selectedIndexPath.row];
        NSLog(@"section: %ld", selectedIndexPath.row);
        if (selectedIndexPath.row == DirectoryMenuNewMembers) {
            memberFilteredController.newMembers = YES;
        }else if (selectedIndexPath.row == DirectoryMenuManagementCommittee) {
            NSLog(@"management: %lu", MemberTypeManagementCommittee);
            memberFilteredController.managementCommittee = YES;
        } else if (selectedIndexPath.row == MemberTypeChapterAdmin){
            memberFilteredController.memberTypeID = MemberTypeChapterAdmin;
            NSLog(@"admin: %lu", MemberTypeChapterAdmin);
        }
    }
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
}
@end
