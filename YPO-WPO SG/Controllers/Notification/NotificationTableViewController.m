//
//  NotificationTableViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NotificationTableViewController.h"
#import "YPONotification.h"
#import "NotificationTableViewCell.h"


@interface NotificationTableViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;

@end

#define BATCHSIZE 15

@implementation NotificationTableViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _currentPage = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [UIView new];
    [self loadMoreData];
    [self fetchData];
}


#pragma - Loading Data

- (void)fetchData {
    NSError *error;
    NSLog(@"notification count: %ld", [YPONotification MR_countOfEntities]);
    if ([self.fetchedResultsController performFetch:&error]) {
        [self.tableView reloadData];
    } else {
        [[YPOErrorhandler sharedHandler] handleError:error];
    }
}


- (void)loadMoreData {
    [self loadDataWithPage:self.currentPage+1];
}


- (void)loadDataWithPage:(NSUInteger)page {
    YPONotificationRequest *request = (YPONotificationRequest *)[YPONotification constructRequest];
    request.page = page;
    request.rowCount = BATCHSIZE;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPage = page;
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[YPOErrorhandler sharedHandler]handleError:error];
    }];
}


#pragma mark - Properties

- (void)setCurrentPage:(NSUInteger)currentPage {
    _currentPage = currentPage;
    [self.fetchRequest setFetchLimit:_currentPage * BATCHSIZE];
}

- (NSFetchedResultsController *)fetchedResultsController {
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:nil cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}


- (NSFetchRequest *)fetchRequest {
    if (_fetchRequest != nil) {
        return _fetchRequest;
    }
    _fetchRequest = [YPONotification MR_requestAllSortedBy:@"sorting" ascending:NO];
    [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
    [_fetchRequest setFetchBatchSize:BATCHSIZE];
    return _fetchRequest;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
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
    return [self tableView:tableView cellForMemberAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForMemberAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"NotificationTableViewCellID";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}




@end


