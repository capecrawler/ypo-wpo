//
//  DirectoryViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "DirectoryViewController.h"

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

@end
