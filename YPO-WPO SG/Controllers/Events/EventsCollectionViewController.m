//
//  EventsCollectionViewController.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "EventsCollectionViewController.h"
#import "YPOEvent.h"
#import "EventCollectionViewCell.h"
#import "EventHeaderView.h"
#import <CSStickyHeaderFlowLayout/CSStickyHeaderFlowLayout.h>
#import "EventDetailsViewController.h"

@interface EventsCollectionViewController ()<NSFetchedResultsControllerDelegate>
@property (nonatomic, assign) NSUInteger currentPage;
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSFetchRequest *fetchRequest;
@end

#define BATCHSIZE 15

@implementation EventsCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self loadMoreData];
    
    [self.collectionView registerClass:[EventCollectionViewCell class] forCellWithReuseIdentifier:@"EventCollectionViewCellID"];
    [self.collectionView registerClass:[EventHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header"];
    
    CSStickyHeaderFlowLayout *flowLayout = [[CSStickyHeaderFlowLayout alloc] init];
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 0, 0, 0);
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [self.collectionView setCollectionViewLayout:flowLayout];
    [self fetchData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma - Loading Data

- (void)fetchData {
    NSError *error;
    if ([self.fetchedResultsController performFetch:&error]) {
        [self.collectionView reloadData];
    } else {
        [[YPOErrorhandler sharedHandler] handleError:error];
    }
}


- (void)loadMoreData {
    [self loadDataWithPage:self.currentPage+1];
}


- (void)loadDataWithPage:(NSUInteger)page {
    YPOEventRequest *request = (YPOEventRequest *)[YPOEvent constructRequest];
    request.page = page;
    request.rowCount = BATCHSIZE;
    [request startRequestSuccess:^(NSURLSessionDataTask *task, id responseObject) {
        self.currentPage = page;
        
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
    NSFetchedResultsController *theFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest managedObjectContext:[NSManagedObjectContext MR_defaultContext] sectionNameKeyPath:@"startMonth" cacheName:nil];
    _fetchedResultsController = theFetchedResultsController;
    _fetchedResultsController.delegate = self;
    return _fetchedResultsController;
}


- (NSFetchRequest *)fetchRequest {
    if (_fetchRequest != nil) {
        return _fetchRequest;
    }
    _fetchRequest = [YPOEvent MR_requestAllSortedBy:@"startDate" ascending:YES];
    [_fetchRequest setFetchLimit:self.currentPage * BATCHSIZE];
    [_fetchRequest setFetchBatchSize:BATCHSIZE];
    return _fetchRequest;
}

#pragma mark - Fetched results controller delegate methods

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self fetchData];
}


#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return [[[self fetchedResultsController] sections] count];
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *const cellID = @"EventCollectionViewCellID";
    EventCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellID forIndexPath:indexPath];
    YPOEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    cell.eventView.titleLabel.text = event.title;
    cell.eventView.detailLabel.text = event.type;
    
    return cell;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10.0f;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.view.bounds.size.width, 60);
}


- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    EventHeaderView * header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"Header" forIndexPath:indexPath];
    YPOEvent *event = [self.fetchedResultsController objectAtIndexPath:indexPath];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM";
    header.monthLabel.text = [formatter stringFromDate:event.startDate];
    formatter.dateFormat = @"dd";
    header.dateLabel.text = [formatter stringFromDate:event.endDate];
    
    return header;
}

#pragma mark <UICollectionViewDelegate>

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    return CGSizeMake(320, 60);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"EventDetailsViewController" sender:self];
}


#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[EventDetailsViewController class]]) {
        EventDetailsViewController *controller = (EventDetailsViewController *)segue.destinationViewController;
        NSIndexPath *selectedIndexPath = [[self.collectionView indexPathsForSelectedItems] firstObject];
        YPOEvent * event = [self.fetchedResultsController objectAtIndexPath:selectedIndexPath];
        controller.event = event;
        [self.collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
    }
}

//- (CGSize)sizingForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static NSString *title                  = @"This is a long title that will cause some wrapping to occur. This is a long title that will cause some wrapping to occur.";
//    static NSString *subtitle               = @"This is a long subtitle that will cause some wrapping to occur. This is a long subtitle that will cause some wrapping to occur.";
//    static NSString *buttonTitle            = @"This is a really long button title that will cause some wrapping to occur.";
//    static CollectionViewCell *sizingCell   = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        sizingCell                          = [[NSBundle mainBundle] loadNibNamed:@"CollectionViewCell" owner:self options:nil][0];
//    });
//    [sizingCell configureWithTitle:title subtitle:[NSString stringWithFormat:@"%@: Number %d.", subtitle, (int)indexPath.row] buttonTitle:buttonTitle];
//    [sizingCell setNeedsLayout];
//    [sizingCell layoutIfNeeded];
//    CGSize cellSize = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//    NSLog(@"cellSize: %@", NSStringFromCGSize(cellSize));
//    return cellSize;
//}


/*
 // Uncomment this method to specify if the specified item should be highlighted during tracking
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
 }
 */

/*
 // Uncomment this method to specify if the specified item should be selected
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }
 */

/*
 // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
 - (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
 }
 
 - (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
 }
 
 - (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
 }
 */


@end