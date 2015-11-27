//
//  ForumTableViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "ForumTableViewController.h"
#import "YPOForum.h"
#import "MembersFilteredViewController.h"


@interface ForumTableViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end


@implementation ForumTableViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self fetchData];
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cancellationToken cancel];
}


#pragma mark - Loading Data

- (void)fetchData {
    NSError *error;
    
    if ([self.fetchedResultsController performFetch:&error]) {
        [self.tableView reloadData];
    } else {
        [[YPOErrorhandler sharedHandler] handleError:error];
    }
}

- (void)loadData {
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPOForumRequest *request = (YPOForumRequest *)[YPOForum constructRequest:self.cancellationToken];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[YPOErrorhandler sharedHandler] handleError:error];
    }];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger numbeOfSections = [self fetchNumbeOfRowsInSection:section];
    return (numbeOfSections > 0)? numbeOfSections+1 : numbeOfSections;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"UITableViewCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (indexPath.row < [self fetchNumbeOfRowsInSection:indexPath.section]) {
        YPOForum *forum = [self.fetchedResultsController objectAtIndexPath:indexPath];
        cell.textLabel.text = forum.name;
    } else {
        cell.textLabel.text = @"Not in Local Forum";
    }
    cell.textLabel.textColor = [UIColor colorBlueTheme];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

- (NSInteger)fetchNumbeOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"MembersFilteredViewController" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
    id controller = segue.destinationViewController;
    if ([controller isKindOfClass:[MembersFilteredViewController class]]) {
        MembersFilteredViewController * filteredController = (MembersFilteredViewController *)controller;
        if (selectedIndexPath.row < [self fetchNumbeOfRowsInSection:selectedIndexPath.section]) {
            filteredController.forumFilter = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        } else {
            filteredController.forumFilter = [YPOForum MR_findFirstByAttribute:@"forumID" withValue:@(-99)];
        }
        filteredController.memberTypeID = MemberTypeAll;
    }
}

#pragma mark - Properties

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"forumID != %@", @(-99)];
    _fetchedResultsController = [YPOForum MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    return _fetchedResultsController;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}


@end
