//
//  MembersFilteredViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MembersFilteredViewController.h"
#import "YPOMember.h"
#import "MemberTableViewCell.h"
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>

#define BATCHSIZE 15

@interface MembersFilteredViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, assign, readwrite)MemberFilterType filterType;


@end

@implementation MembersFilteredViewController

- (void) awakeFromNib {
    [super awakeFromNib];
    self.loadingData = NO;
    self.currentPage = 0;
    self.fetchRequest = nil;
    self.filterType = MemberFilterNew;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberCellIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    [self fetchData];
    [self loadMoreData];
    
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
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest];
    request.page = page;
    if (self.filterType == MemberFilterForum) {
        request.forumID = [self.forumFilter.forumID integerValue];
    } else if (self.filterType == MemberFilterChapter) {
        request.chapterID = [self.chapterFilter.chapterID integerValue];
    } else {
        request.newMembers = YES;
    }
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
    return [self tableView:tableView cellForMemberAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForMemberAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"MemberCellIdentifier";
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.member = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - Properties

- (void) setChapterFilter:(YPOChapter *)chapterFilter {
    _chapterFilter = chapterFilter;
    self.filterType = MemberFilterChapter;
    self.fetchRequest = nil;
    self.currentPage = 0;
    self.title = chapterFilter.name;
}

- (void) setForumFilter:(YPOForum *)forumFilter {
    _forumFilter = forumFilter;
    self.filterType = MemberFilterForum;
    self.fetchRequest = nil;
    self.currentPage = 0;
    self.title = forumFilter.name;
}

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
    
    if (self.filterType == MemberFilterChapter) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY chapterOrg.chapterID >= %@", self.chapterFilter.chapterID];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    } else if (self.filterType == MemberFilterForum) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"ANY forum.forumID >= %@", self.forumFilter.forumID];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    } else {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setMonth:-1];
        NSDate *oneMonthAgo = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"joinedDate >= %@", oneMonthAgo];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"joinedDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    }
    
    return _fetchRequest;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}



@end
