//
//  YPONotification.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/25/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"


@interface YPONotification : YPORemoteManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSNumber * notificationID;
@property (nonatomic, retain) NSDate * postDate;
@property (nonatomic, retain) NSString * thumbURL;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate *startDate;
@property (nonatomic, retain) NSDate *endDate;
@property (nonatomic, retain) NSDate *sorting;
@property (nonatomic, retain) NSNumber * articleID;
@property (nonatomic, retain) NSString * articleTitle;

+ (void)purgeData;

@end



@interface YPONotificationRequest : YPOHTTPRequest

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger rowCount;

@end