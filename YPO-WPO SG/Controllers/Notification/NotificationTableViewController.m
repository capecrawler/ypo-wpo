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
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>
#import "YPOEvent.h"
#import "YPOArticle.h"
#import "YPOMember.h"
#import "EventDetailsViewController.h"
#import "NewsDetailsViewController.h"
#import "MemberDetailsViewController.h"

@interface NotificationTableViewController()<NSFetchedResultsControllerDelegate>

@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) NSManagedObjectContext *temporaryContext;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

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
    
    [self.tableView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        self.currentPage = 0;
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:defaultFrame backImage:nil frontImage:[UIImage imageNamed:@"ic-loader"]];
    
    self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.tableView.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
    
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];

    
    [self loadMoreData];
    [self fetchData];
}


#pragma - Loading Data

- (void)fetchData {
    NSError *error;
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
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPONotificationRequest *request = (YPONotificationRequest *)[YPONotification constructRequest:self.cancellationToken];
    request.page = page;
    request.rowCount = BATCHSIZE;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPage = page;
        [self.tableView ins_endPullToRefresh];
        NSDictionary *paging = responseObject[@"paging"];
        if ([paging[@"next"]integerValue] == 0) {
            self.tableView.ins_infiniteScrollBackgroundView.enabled = NO;
            [self.tableView ins_endInfinityScrollWithStoppingContentOffset:NO];
        } else {
            self.tableView.ins_infiniteScrollBackgroundView.enabled = YES;
            [self.tableView ins_endInfinityScrollWithStoppingContentOffset:YES];
        }
        [self fetchData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [[YPOErrorhandler sharedHandler]handleError:error];
    }];
}


- (YPOEvent *)fetchOrCreateEventWithID:(NSNumber *)eventID {
    YPOEvent *event = [YPOEvent MR_findFirstByAttribute:@"eventID" withValue:eventID inContext:self.temporaryContext];
    if (event == nil) {
        event =  [YPOEvent MR_createEntityInContext:self.temporaryContext];
        event.eventID = eventID;
    }
    return event;
}


- (YPOArticle *)fetchOrCreateArticleWithID:(NSNumber *)articleID {
    YPOArticle *article = [YPOArticle MR_findFirstByAttribute:@"articleID" withValue:articleID inContext:self.temporaryContext];
    if (article == nil) {
        article = [YPOArticle MR_createEntityInContext:self.temporaryContext];
        article.articleID = articleID;
    }
    return article;
}

- (YPOMember *)fetchOrCreateMemberWithID:(NSNumber *)memberID {
    YPOMember *member = [YPOMember MR_findFirstByAttribute:@"memberID" withValue:memberID inContext:self.temporaryContext];
    if (member == nil) {
        member = [YPOMember MR_createEntityInContext:self.temporaryContext];
        member.memberID = memberID;
    }
    return member;
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


- (NSManagedObjectContext *)temporaryContext {
    if (_temporaryContext == nil) {
        _temporaryContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
    }
    return _temporaryContext;
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
    return [self tableView:tableView cellForNotificationAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNotificationAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"NotificationTableViewCellID";
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    YPONotification *notification = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    if ([notification.type isEqualToString:@"event"]) {
        [self performSegueWithIdentifier:@"EventDetailsViewController" sender:self];
    } else if ([notification.type isEqualToString:@"comment"] || [notification.type isEqualToString:@"news"]) {
        [self performSegueWithIdentifier:@"NewsDetailsViewController" sender:self];
    } else if ([notification.type isEqualToString:@"member"]) {
        [self performSegueWithIdentifier:@"MemberDetailsViewController" sender:self];
    }
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath *selectedIndexPath = self.tableView.indexPathForSelectedRow;
    UIViewController *controller = segue.destinationViewController;
    YPONotification *notification = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
    if ([controller isKindOfClass:[NewsDetailsViewController class]]) {
        NewsDetailsViewController *newsController = (NewsDetailsViewController *)controller;
        NSNumber *articleID = ([notification.type isEqualToString:@"comment"])?notification.articleID: notification.notificationID;
        NSString *articleTitle = ([notification.type isEqualToString:@"comment"])?notification.articleTitle: notification.title;
        YPOArticle *article = [self fetchOrCreateArticleWithID:articleID];
        article.title = articleTitle;
        newsController.article = article;
    } else if ([controller isKindOfClass:[EventDetailsViewController class]]) {
        EventDetailsViewController *eventController = (EventDetailsViewController *)controller;
        eventController.eventID = notification.notificationID;
    } else if ([controller isKindOfClass:[MemberDetailsViewController class]]) {
        MemberDetailsViewController *memberController = (MemberDetailsViewController *)controller;
        memberController.memberID = notification.notificationID;
    }
    
    [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];

}





@end

