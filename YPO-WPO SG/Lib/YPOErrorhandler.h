//
//  YPOErrorhandler.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/27/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YPOErrorhandler : NSObject

+ (instancetype)sharedHandler;
- (void) handlerError:(NSError *)error;


@end
