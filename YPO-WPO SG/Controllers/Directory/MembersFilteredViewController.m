//
//  MembersFilteredViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MembersFilteredViewController.h"
#import "MemberTableViewCell.h"
#import "MemberDetailsViewController.h"
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#define BATCHSIZE 15

@interface MembersFilteredViewController()<NSFetchedResultsControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, assign, readwrite)MemberFilterType filterType;
@property (nonatomic, strong) NSError *requestError;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end

@implementation MembersFilteredViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _loadingData = NO;
        _currentPage = 0;
        _fetchRequest = nil;
        _filterType = MemberFilterNone;
        _memberTypeID = MemberTypeAll;
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberCellIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    
    [self loadMoreData];
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
    self.loadingData = YES;
    self.requestError = nil;
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest:self.cancellationToken];
    request.page = page;
    request.memberTypeID = self.memberTypeID;    
    if (self.filterType == MemberFilterForum) {
        request.forumID = [self.forumFilter.forumID integerValue];
        request.newMembers = NO;
    } else if (self.filterType == MemberFilterChapter) {
//        request.chapterID = [self.chapterFilter.chapterID integerValue];
        request.newMembers = NO;
    } else if (self.filterType == MemberFilterManagementCommittee) {
        request.managementCommittee = YES;
    }
    
    if (self.newMembers) {
        request.newMembers = YES;
    } else {
        request.newMembers = NO;
    }
    
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPage = page;
        if ([responseObject[@"status"] boolValue]) {
            NSDictionary *paging = responseObject[@"paging"];
            if ([paging[@"next"]integerValue] == 0) {
                self.tableView.ins_infiniteScrollBackgroundView.enabled = NO;
                [self.tableView ins_endInfinityScrollWithStoppingContentOffset:YES];
            } else {
                self.tableView.ins_infiniteScrollBackgroundView.enabled = YES;
                [self.tableView ins_endInfinityScrollWithStoppingContentOffset:NO];
            }
        } else {
                [self.tableView ins_endInfinityScrollWithStoppingContentOffset:NO];
        }
        self.loadingData = NO;
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.loadingData = NO;
        self.requestError = error;
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
    YPOMember *member = [self.fetchedResultsController objectAtIndexPath:indexPath];
    if (self.memberTypeID == MemberTypeChapterAdmin) {
        cell.showJoinedDate = NO;
    } else {
        cell.showJoinedDate = YES;
    }
    if (self.filterType == MemberFilterManagementCommittee ||
        self.filterType == MemberFilterChapter) {
        cell.showRole = YES;
    } else {
        cell.showRole = NO;
    }
    
    
    cell.member = member;    
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"MemberDetailsViewController" sender:self];
}



#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id controller = [segue destinationViewController];
    if ([controller isKindOfClass:[MemberDetailsViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MemberDetailsViewController *memberController = (MemberDetailsViewController *)controller;
        memberController.memberID = [[self.fetchedResultsController objectAtIndexPath:selectedIndexPath] memberID];
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


#pragma mark - Properties

- (void)setChapterFilter:(YPOChapter *)chapterFilter {
    _chapterFilter = chapterFilter;
    self.filterType = MemberFilterChapter;
    self.memberTypeID = MemberTypeMembers;
    self.fetchRequest = nil;
    self.currentPage = 0;
    self.title = chapterFilter.name;
}

- (void)setForumFilter:(YPOForum *)forumFilter {
    _forumFilter = forumFilter;
    self.filterType = MemberFilterForum;
    self.memberTypeID = MemberTypeMembers;
    self.fetchRequest = nil;
    self.currentPage = 0;
    if (forumFilter != nil) {
        self.title = forumFilter.name;
    } else {
        self.title = @"Not in Local Forum";
    }
}

- (void)setMemberTypeID:(MemberTypeID)memberTypeID {
    _memberTypeID = memberTypeID;
    self.fetchRequest = nil;
}

- (void)setManagementCommittee:(BOOL)managementCommittee {
    _managementCommittee = managementCommittee;
    self.filterType = MemberFilterManagementCommittee;
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
    
    
    if (self.filterType == MemberFilterForum) {
        
        NSPredicate *predicate = nil;
       predicate = [NSPredicate predicateWithFormat:@"ANY forum.forumID == %@", self.forumFilter.forumID];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    } else if (self.filterType == MemberFilterChapter) {
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberType == %@ &&  chapterOrg.chapterID == %@", @(self.memberTypeID) , self.chapterFilter.chapterID];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"memberType == %@", @(self.memberTypeID)];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"name" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    } else if (self.filterType == MemberFilterManagementCommittee) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"managementCommittee == %@", @(YES)];
        _fetchRequest = [YPOMember MR_requestAllSortedBy:@"managementCommitteeOrder" ascending:YES withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
        [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
        [_fetchRequest setFetchBatchSize:BATCHSIZE];
    } else {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setYear:-1];
        NSDate *oneMonthAgo = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        
        NSPredicate *predicate;
        if (self.newMembers) {
            // YPO members only
            predicate = [NSPredicate predicateWithFormat:@"joinedDate >= %@ && chapterOrg.chapterID == %@", oneMonthAgo, @(1)];
        } else {
            predicate = [NSPredicate predicateWithFormat:@"memberType == %@", @(self.memberTypeID)];
        }
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


#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text;
    if (self.requestError) {
        text = NSLocalizedString(@"Whooops", nil);
    } else {
        text = NSLocalizedString(@"How Sad", nil);
    }
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:17.0], NSForegroundColorAttributeName: self.view.tintColor};
    return [[NSAttributedString alloc] initWithString:@"Refresh" attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text;
    if (self.requestError) {
        text = self.requestError.localizedDescription;
    } else {
        text = NSLocalizedString(@"No members found. :(", nil);
    }
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:14.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

#pragma mark - DZNEmptyDataSetDelegate


- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    return !self.loadingData;
}


- (void)emptyDataSetDidTapButton:(UIScrollView *)scrollView {
    [self loadMoreData];
    [self.tableView reloadData];
}


@end
