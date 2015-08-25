//
//  MembersListViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "MembersListViewController.h"
#import "YPOMember.h"
#import "MemberTableViewCell.h"
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>
#import "MemberDetailsViewController.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import "TableViewHeader.h"
#define BATCHSIZE 15

@interface MembersListViewController()<UISearchBarDelegate, UISearchDisplayDelegate, NSFetchedResultsControllerDelegate, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;

@property (nonatomic, strong) NSArray *searchResult;
@property (nonatomic, assign) BOOL                          didSelectedSearchTableViewCell;

@property (nonatomic, assign) BOOL loadingData;
@property (nonatomic, assign) NSError *requestError;

@end

@implementation MembersListViewController

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _loadingData = NO;
        _currentPage = 0;
    }
    return self;
}


- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
    
    // A little trick for removing the cell separators
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberCellIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    
    [self.searchDisplayController.searchResultsTableView registerNib:[UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberCellIdentifier"];
    self.searchDisplayController.searchResultsTableView.tableFooterView = [UIView new];
    
    [self loadMoreData];
    [self fetchData];
    
    
    
    
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
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest];
    request.page = page;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.loadingData = NO;
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
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        self.loadingData = NO;
        self.requestError = error;
        [self.tableView reloadData];
    }];
}


#pragma mark - Search

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller {
    self.searchResult = nil;
}


- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filter:searchString];
    return NO;
}

-(void)filter:(NSString*)text {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(firstName BEGINSWITH[cd] %@)", text];
    self.searchResult = [YPOMember MR_findAllWithPredicate:predicate];
    [self.searchDisplayController.searchResultsTableView reloadData];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.searchDisplayController.searchResultsTableView == tableView)return 1;
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.searchDisplayController.searchResultsTableView == tableView) return self.searchResult.count;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [self tableView:tableView cellForMemberAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForMemberAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"MemberCellIdentifier";
    MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.showJoinedDate = NO;
    if (self.searchDisplayController.searchResultsTableView == tableView) {
        cell.member = self.searchResult[indexPath.row];
    } else {
        cell.member = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (self.searchDisplayController.searchResultsTableView == tableView) return nil;
    TableViewHeader * headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeader" owner:self options:nil] lastObject];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    headerView.textLabel.text = [[[self.fetchedResultsController sections] objectAtIndex:section] name];
    return headerView;
}


- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    if (tableView == self.searchDisplayController.searchResultsTableView) return nil;
    return [self.fetchedResultsController sectionIndexTitles];
}


- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    if (tableView == self.searchDisplayController.searchResultsTableView) return 0;
    return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}


#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) return 0;
    return 32;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 76;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        self.didSelectedSearchTableViewCell = YES;
    } else {
        self.didSelectedSearchTableViewCell = NO;
    }
    [self performSegueWithIdentifier:@"MemberDetailsViewController" sender:self];    
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id controller = [segue destinationViewController];
    if ([controller isKindOfClass:[MemberDetailsViewController class]]) {
        NSIndexPath *selectedIndexPath;
        YPOMember *member;
        if (self.didSelectedSearchTableViewCell) {
            selectedIndexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            member = self.searchResult[selectedIndexPath.row];
        } else {
            selectedIndexPath = [self.tableView indexPathForSelectedRow];
            member = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        }
        MemberDetailsViewController *memberController = (MemberDetailsViewController *)controller;
        memberController.memberID = member.memberID;
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
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:@"firstLetterName" cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}


- (NSFetchRequest *)fetchRequest {
    if (_fetchRequest != nil) {
        return _fetchRequest;
    }
    _fetchRequest = [YPOMember MR_requestAllSortedBy:@"name" ascending:YES];
    [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
    [_fetchRequest setFetchBatchSize:BATCHSIZE];
    return _fetchRequest;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    if (!self.searchDisplayController.isActive)
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
