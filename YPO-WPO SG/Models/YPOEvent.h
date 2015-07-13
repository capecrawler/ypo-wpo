//
//  YPOEvent.h
//  YPO-WPO SG
//
//  Created by Mario Antonio A. Cape on 7/12/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YPORemoteManagedObject.h"


@interface YPOEvent : YPORemoteManagedObject

@property (nonatomic, retain) NSNumber * eventID;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * thumbUrl;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSDate * endDate;

- (NSString *)startMonth;

@end


@interface YPOEventRequest : YPOHTTPRequest

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger rowCount;

@end