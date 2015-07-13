//
//  YPOEventFlowLayout.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOEventFlowLayout.h"

@implementation YPOEventFlowLayout

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray *allItems = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
    
    __block BOOL headerFound = NO;
    __block BOOL footerFound = NO;
    [allItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([[obj representedElementKind] isEqualToString:UICollectionElementKindSectionHeader]) {
            headerFound = YES;
            [self updateHeaderAttributes:obj];
        } else if ([[obj representedElementKind] isEqualToString:UICollectionElementKindSectionFooter]) {
            footerFound = YES;
            [self updateFooterAttributes:obj];
        }
    }];
    
    
    // Flow layout will remove items from the list if they are supposed to be off screen, so we add them
    // back in in those cases.
    if (!headerFound) {
        [allItems addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:[NSIndexPath indexPathForItem:[allItems count] inSection:0]]];
    }
    if (!footerFound) {
        [allItems addObject:[self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:[NSIndexPath indexPathForItem:[allItems count] inSection:0]]];
    }
    
    return allItems;
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewLayoutAttributes *attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:kind withIndexPath:indexPath];
    attributes.size = CGSizeMake(self.collectionView.bounds.size.width, 44);
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        [self updateHeaderAttributes:attributes];
    } else {
        [self updateFooterAttributes:attributes];
    }
    return attributes;
}

- (void)updateHeaderAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    CGRect currentBounds = self.collectionView.bounds;
    attributes.zIndex = 1;
    attributes.hidden = NO;
    CGFloat yCenterOffset = 64 + currentBounds.origin.y + attributes.size.height/2.f;
    attributes.center = CGPointMake(CGRectGetMidX(currentBounds), yCenterOffset);
}

- (void)updateFooterAttributes:(UICollectionViewLayoutAttributes *)attributes
{
    CGRect currentBounds = self.collectionView.bounds;
    attributes.zIndex = 1;
    attributes.hidden = NO;
    CGFloat yCenterOffset = currentBounds.origin.y + currentBounds.size.height - attributes.size.height/2.0f;
    attributes.center = CGPointMake(CGRectGetMidX(currentBounds), yCenterOffset);
}

@end
