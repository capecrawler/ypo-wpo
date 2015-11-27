//
//  YPOCancellationToken.m
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 11/28/15.
//  Copyright © 2015 Raketeers. All rights reserved.
//

#import "YPOCancellationToken.h"

@implementation YPOCancellationToken

- (void)cancel {
    self.cancelled = YES;
}

@end
