//
//  CommentsViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/29/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "CommentsViewController.h"
#import "CommentTextView.h"
#import "YPOArticle.h"
#import "YPOComment.h"
#import "CommentTableViewCell.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import <INSPullToRefresh/INSDefaultInfiniteIndicator.h>
#import <INSPullToRefresh/UIScrollView+INSPullToRefresh.h>

#define BATCHSIZE 15

@interface CommentsViewController()<NSFetchedResultsControllerDelegate>
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@property (nonatomic, strong) YPOCancellationToken *cancellationToken;

@end


@implementation CommentsViewController

- (id)init {
    self = [super initWithTableViewStyle:UITableViewStylePlain];
    if (self) {
        [self registerClassForTextView:[CommentTextView class]];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self registerClassForTextView:[CommentTextView class]];
    }
    return self;
}

+ (UITableViewStyle)tableViewStyleForCoder:(NSCoder *)decoder {
    return UITableViewStylePlain;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView ins_addInfinityScrollWithHeight:60 handler:^(UIScrollView *scrollView) {
        [self loadMoreData];
    }];
    
    CGRect defaultFrame = CGRectMake(0, 0, 24, 24);
    UIView <INSAnimatable> *infinityIndicator = [[INSDefaultInfiniteIndicator alloc] initWithFrame:defaultFrame];
    [self.tableView.ins_infiniteScrollBackgroundView addSubview:infinityIndicator];
    [infinityIndicator startAnimating];
    
    self.bounces = YES;
    self.shakeToClearEnabled = YES;
    self.keyboardPanningEnabled = YES;
    self.shouldScrollToBottomAfterKeyboardShows = NO;
    self.inverted = YES;
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[CommentTableViewCell class] forCellReuseIdentifier:@"CommentTableViewCell"];
    
    [self.rightButton setTitle:NSLocalizedString(@"Post", nil) forState:UIControlStateNormal];
    self.textInputbar.autoHideRightButton = NO;
    self.textInputbar.maxCharCount = 256;
    self.textInputbar.counterStyle = SLKCounterStyleSplit;
    self.textInputbar.counterPosition = SLKCounterPositionTop;
    self.shouldClearTextAtRightButtonPress = NO;
    self.textView.keyboardType = UIKeyboardTypeDefault;
    
    self.typingIndicatorView.canResignByTouch = YES;
    
    [self fetchData];
    [self loadMoreData];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.cancellationToken cancel];
}


#pragma mark - Loading Data

- (void)loadMoreData{
    [self loadDataWithPage:self.currentPage+1];
}

- (void)loadDataWithPage:(NSUInteger)page {
    self.cancellationToken = [[YPOCancellationToken alloc] init];
    YPOCommentRequest *request = (YPOCommentRequest *)[YPOComment constructRequest:self.cancellationToken];
    request.page = page;
    request.rowCount = BATCHSIZE;
    request.articleID = @(self.articleID);
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


- (void)fetchData {
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        [self.tableView reloadData];
    } else {
        [[YPOErrorhandler sharedHandler] handleError:error];
    }
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
    return [self tableView:tableView cellForCommentAtIndexPath:indexPath];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForCommentAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellId = @"CommentTableViewCell";
    CommentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
    cell.comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.transform = tableView.transform;
    
    return cell;
}


#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tableView isEqual:self.tableView]) {
        YPOComment *comment = [self.fetchedResultsController objectAtIndexPath:indexPath];
        
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        paragraphStyle.alignment = NSTextAlignmentLeft;
        
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        NSDictionary *attributesDate = @{NSFontAttributeName: [UIFont systemFontOfSize:13.0],
                                     NSParagraphStyleAttributeName: paragraphStyle};
        
        CGFloat width = CGRectGetWidth(tableView.frame)-kAvatarSize;
        width -= 25.0;
        
        CGRect titleBounds = [comment.name boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        CGRect datePosted = [comment.postDateFormatted boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributesDate context:NULL];
        CGRect bodyBounds = [comment.comment boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:NULL];
        
        if (comment.comment.length == 0) {
            return 0.0;
        }
        
        CGFloat height = CGRectGetHeight(titleBounds);
        height += CGRectGetHeight(datePosted);
        height += CGRectGetHeight(bodyBounds);
        height += 40.0;
        
        if (height < kMinimumHeight) {
            height = kMinimumHeight;
        }
        
        return height;
    }
    else {
        return kMinimumHeight;
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
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"article.articleID == %@", self.articleID];
    _fetchRequest = [YPOComment MR_requestAllSortedBy:@"postDate" ascending:NO withPredicate:predicate];
    [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
    [_fetchRequest setFetchBatchSize:BATCHSIZE];
    return _fetchRequest;
}



#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}


#pragma mark - Overriden Methods

- (void)didPressRightButton:(id)sender {
    [self dismissKeyboard:YES];
    NSManagedObjectContext *localContext = [NSManagedObjectContext MR_contextWithParent:[NSManagedObjectContext MR_defaultContext]];
    
//    YPOArticle *article = [self.article MR_inContext:localContext];
    YPOArticle *article = [YPOArticle MR_findFirstByAttribute:@"articleID" withValue:@(self.articleID) inContext:localContext];
    
    YPOComment *comment = [YPOComment MR_createEntityInContext:localContext];
    comment.comment = [self.textView.text copy];
    
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *memberID = [f numberFromString:[[NSUserDefaults standardUserDefaults] stringForKey:@"memberID"]];
    
    comment.memberID = memberID;
    comment.article = article;

    [SVProgressHUD showWithStatus:@"Posting..." maskType:SVProgressHUDMaskTypeGradient];
    [comment saveToRemoteSucess:^(NSURLSessionDataTask *task, id responseObject) {
        [SVProgressHUD dismiss];
        [self.textView slk_clearText:YES];
        self.currentPage = 0;
        [self loadMoreData];
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription maskType:SVProgressHUDMaskTypeGradient];
    }];
    
    [super didPressRightButton:self];
}

@end
