//
//  YPOForum.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 6/30/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"

@class YPOMember;

@interface YPOForum : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * forumID;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) YPOMember *members;

@end


@interface YPOForumRequest : YPOHTTPRequest


@end