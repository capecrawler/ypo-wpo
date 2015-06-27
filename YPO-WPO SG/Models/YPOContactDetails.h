//
//  YPOContactDetails.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/28/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

@class YPOMember;

@interface YPOContactDetails : YPORemoteManagedObject

@property (nonatomic, retain) NSString * business;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * home;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) YPOMember *member;

@end
