//
//  NewsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NewsViewController.h"
#import "YPOArticle.h"
#import "NewsTableViewCell.h"
#import "NewsDetailsViewController.h"
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>

#define BATCHSIZE 15

@interface NewsViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end

@implementation NewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.currentPage = 0;
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NewsCellIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    [self fetchData];
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


- (void)loadMoreData{
    [self loadDataWithPage:self.currentPage+1];
}

- (void)loadDataWithPage:(NSUInteger)page {
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPOArticleRequest *request = (YPOArticleRequest*)[YPOArticle constructRequest:self.cancellationToken];
    request.page = page;
    request.rowCount = BATCHSIZE;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPage = page;
        NSDictionary *paging = responseObject[@"paging"];
        if ([paging[@"next"]integerValue] == 0) {
            self.tableView.ins_infiniteScrollBackgroundView.enabled = NO;
            [self.tableView ins_endInfinityScrollWithStoppingContentOffset:YES];
        } else {
            [self.tableView ins_endInfinityScrollWithStoppingContentOffset:NO];
        }
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[YPOErrorhandler sharedHandler]handleError:error];
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
    return [self tableView:tableView cellForNewsAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNewsAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"NewsCellIdentifier";
    NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.article = [self.fetchedResultsController objectAtIndexPath:indexPath];

    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 96;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"NewsDetailsViewController" sender:self];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id controller = [segue destinationViewController];
    if ([controller isKindOfClass:[NewsDetailsViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NewsDetailsViewController *newsDetailsController = (NewsDetailsViewController *)controller;
        newsDetailsController.article = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
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
    _fetchRequest = [YPOArticle MR_requestAllSortedBy:@"postDate" ascending:NO];
    [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
    [_fetchRequest setFetchBatchSize:BATCHSIZE];
    return _fetchRequest;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}


@end
