//
//  NewsfeedViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/11/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "NewsfeedViewController.h"
#import "YPOArticle.h"
#import "YPOMember.h"
#import "TableViewHeader.h"
#import "NewsTableViewCell.h"
#import "MemberTableViewCell.h"
#import <Bolts/Bolts.h>
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>
#import <INSPullToRefresh/INSDefaultPullToRefresh.h>
#import "YPOSyncManager.h"
#import "NewsDetailsViewController.h"
#import "MemberDetailsViewController.h"


typedef NS_ENUM(NSUInteger, YPONewsfeedSection) {
    YPONewsfeedSectionArticle = 0,
    YPONewsfeedSectionMembers
    
};


@interface NewsfeedViewController ()

@property (nonatomic, strong) NSArray *news;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, assign) BOOL showMoreNews;
@property (nonatomic, assign) BOOL showMoreNewMembers;

@end

@implementation NewsfeedViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 50, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(64, 0, 50, 0);
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    
    [self.tableView ins_addPullToRefreshWithHeight:60.0 handler:^(UIScrollView *scrollView) {
        [self loadData];
    }];
    
    UIView <INSPullToRefreshBackgroundViewDelegate> *pullToRefresh = [[INSDefaultPullToRefresh alloc] initWithFrame:defaultFrame backImage:nil frontImage:[UIImage imageNamed:@"ic-loader"]];
    
    self.tableView.ins_pullToRefreshBackgroundView.delegate = pullToRefresh;
    [self.tableView.ins_pullToRefreshBackgroundView addSubview:pullToRefresh];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"NewsCellIdentifier"];
    [self.tableView registerNib:[UINib nibWithNibName:@"MemberTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"MemberCellIdentifier"];
    self.tableView.tableFooterView = [UIView new];
    
    
    
    NSNotificationCenter *dnc = [NSNotificationCenter defaultCenter];
//    [dnc addObserver:self
//            selector:@selector(dataDidStartLoading:)
//                name:YPODataFinishedLoadingNotification
//              object:nil];
    [dnc addObserver:self
            selector:@selector(loadData)
                name:UIApplicationDidBecomeActiveNotification
              object:nil];
    [dnc addObserver:self
            selector:@selector(dataDidFinishLoading:)
                name:YPODataFinishedLoadingNotification
              object:nil];
    [dnc addObserver:self
            selector:@selector(dataDidFailedLoading:)
                name:YPODataFailedToLoadNotification
              object:nil];
    
    [self fetch];
    [self loadData];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id controller = [segue destinationViewController];
    if ([controller isKindOfClass:[NewsDetailsViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        NewsDetailsViewController *newsDetailsController = (NewsDetailsViewController *)controller;
        newsDetailsController.article = self.news[selectedIndexPath.row];
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    } else if ([controller isKindOfClass:[MemberDetailsViewController class]]) {
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        MemberDetailsViewController *memberController = (MemberDetailsViewController *)controller;
        memberController.memberID = [self.members[selectedIndexPath.row] memberID];
        [self.tableView deselectRowAtIndexPath:selectedIndexPath animated:YES];
    }
}


#pragma mark - Loading Data

- (void)dataDidStartLoading:(NSNotification *)notification {
    [self.tableView ins_beginPullToRefresh];
}

- (void)dataDidFinishLoading:(NSNotification *)notification {
    [self.tableView ins_endPullToRefresh];
    [self fetch];
}

- (void)dataDidFailedLoading:(NSNotification *)notification {
    [self.tableView ins_endPullToRefresh];
    [self fetch];
}

- (void)fetch {

    // Members
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    [offsetComponents setYear:-1];
    NSDate *oneMonthAgo = [gregorian dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"joinedDate >= %@", oneMonthAgo];
    
    NSFetchRequest *request = [YPOMember MR_requestAllSortedBy:@"joinedDate" ascending:NO withPredicate:predicate inContext:[NSManagedObjectContext MR_defaultContext]];
    request.fetchLimit = 3;
    
    self.members = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:request error:nil];
    NSUInteger newMembersCount = [YPOMember MR_countOfEntitiesWithPredicate:predicate];
    if (newMembersCount > self.members.count) {
        self.showMoreNewMembers = YES;
    } else {
        self.showMoreNewMembers = NO;
    }
    
    
    // Articles
    request = [YPOArticle MR_requestAllSortedBy:@"postDate" ascending:NO];
    NSUInteger articleLimit;
    if (self.members.count > 0) {
        request.fetchLimit = 3;
        articleLimit = 3;
    } else {
        request.fetchLimit = 15;
        articleLimit = 15;
    }
    
    NSUInteger articleCount = [YPOArticle MR_countOfEntities];
    if (articleCount > articleLimit) {
        self.showMoreNews = YES;
    } else {
        self.showMoreNews = NO;
    }
    
    self.news = [[NSManagedObjectContext MR_defaultContext] executeFetchRequest:request error:nil];
    
    [self.tableView reloadData];
}


- (void)loadData {
    if ([[[NSUserDefaults standardUserDefaults] stringForKey:@"memberID"]isNotEmpty]) {
        [self.tableView ins_beginPullToRefresh];
        if (![YPOSyncManager sharedManager].isSyncing) {
            [[YPOSyncManager sharedManager] startSync];
        }
    }
}


- (BFTask *)loadArticles {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOArticleRequest *request = (YPOArticleRequest*)[YPOArticle constructRequest];
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


- (BFTask *)loadNewMembers {
    BFTaskCompletionSource *requestTask = [BFTaskCompletionSource taskCompletionSource];
    YPOMemberRequest *request = (YPOMemberRequest*)[YPOMember constructRequest];
    request.newMembers = YES;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        [requestTask setResult:responseObject];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [requestTask setError:error];
    }];
    return requestTask.task;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.news.count == 0 && self.members.count == 0) {
        return 0;
    } else {
        return 1 + ((self.members.count > 0)?1:0);
    }
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == YPONewsfeedSectionArticle) {
        return self.news.count + ((self.showMoreNews)?1:0);
    } else if (section == YPONewsfeedSectionMembers) {
        return self.members.count + ((self.showMoreNewMembers)?1:0);
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YPONewsfeedSectionArticle) {
        return [self tableView:tableView cellForNewsAtIndexPath:indexPath];
    } else if (indexPath.section == YPONewsfeedSectionMembers) {
        return [self tableView:tableView cellForMembersAtIndexPath:indexPath];
    }
    return [self tableView:tableView cellForMessageRowAtIndexPath:indexPath];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForNewsAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.news.count) {
        static NSString *cellId = @"NewsCellIdentifier";
        NewsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        cell.article = self.news[indexPath.row];
        return cell;
    } else {
        UITableViewCell *cell = [self tableView:tableView cellForMessageRowAtIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Show more...", nil);
        return cell;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForMembersAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.members.count) {
        static NSString *cellId = @"MemberCellIdentifier";
        MemberTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        cell.member = self.members[indexPath.row];
        return cell;
    }else {
        UITableViewCell *cell = [self tableView:tableView cellForMessageRowAtIndexPath:indexPath];
        cell.textLabel.text = NSLocalizedString(@"Show more...", nil);
        return cell;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForMessageRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YPONewsfeedSectionArticle) {
        if (indexPath.row < self.news.count) {
            return 96;
        } else {
            return 44;
        }
    } else if (indexPath.section == YPONewsfeedSectionMembers) {
        if (indexPath.row < self.members.count) {
            return 76;
        } else {
            return 44;
        }
    }
    return 44;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    TableViewHeader * headerView = [[[NSBundle mainBundle] loadNibNamed:@"TableViewHeader" owner:self options:nil] lastObject];
    headerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    if (section == YPONewsfeedSectionArticle) {
        headerView.textLabel.text = NSLocalizedString(@"CURRENT NEWS", @"news table header");
    } else if (section == YPONewsfeedSectionMembers) {
        headerView.textLabel.text = NSLocalizedString(@"NEW MEMBERS", @"members table header");
    } else {
        headerView.textLabel.text = @"";
    }

    return headerView;
}


- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == YPONewsfeedSectionArticle) {
        if (indexPath.row < self.news.count) {
            [self performSegueWithIdentifier:@"NewsDetailsViewController" sender:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self performSegueWithIdentifier:@"NewsViewController" sender:self];
        }
    } else if (indexPath.section == YPONewsfeedSectionMembers) {
        if (indexPath.row < self.members.count) {
            [self performSegueWithIdentifier:@"MemberDetailsViewController" sender:self];
        } else {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self performSegueWithIdentifier:@"MembersFilteredViewController" sender:self];
        }
    }
}

@end
