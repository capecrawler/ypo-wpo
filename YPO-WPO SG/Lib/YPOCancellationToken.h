//
//  YPOCancellationToken.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 11/28/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPOCancellationToken : NSObject

@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;
- (void)cancel;

@end
