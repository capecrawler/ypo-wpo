//
//  ChapterTableViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "ChapterTableViewController.h"
#import "YPOChapter.h"
#import "MembersFilteredViewController.h"

@interface ChapterTableViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end


@implementation ChapterTableViewController


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
    YPOChapterRequest *request = (YPOChapterRequest *)[YPOChapter constructRequest:self.cancellationToken];
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
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    YPOChapter *forum = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = forum.name;
    cell.textLabel.textColor = [UIColor colorBlueTheme];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
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
        filteredController.chapterFilter = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        filteredController.memberTypeID = self.memberTypeID;
    }
}


#pragma mark - Properties

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    _fetchedResultsController = [YPOChapter MR_fetchAllSortedBy:@"name" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    return _fetchedResultsController;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}



@end
