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
@property (nonatomic, retain) NSString * location;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * capacityLimit;
@property (nonatomic, retain) NSString * parking;
@property (nonatomic, retain) NSString * registrationStatus;
@property (nonatomic, retain) NSString * resource;
@property (nonatomic, retain) NSString * eventDescription;
@property (nonatomic, retain) NSNumber * inviteeTypeID;
@property (nonatomic, retain) NSString * inviteeType;
@property (nonatomic, retain) NSString * rsvpName;
@property (nonatomic, retain) NSString * rsvpEmail;


- (NSString *)startMonth;
- (NSAttributedString *)formattedDescriptionWithFont:(UIFont *)font textColor:(UIColor *)textColor;
- (NSAttributedString *)formattedResourceWithFont:(UIFont *)font textColor:(UIColor *)textColor;
+ (void)purgeData;

@end


@interface YPOEventRequest : YPOHTTPRequest

@property (nonatomic, assign) NSUInteger page;
@property (nonatomic, assign) NSUInteger rowCount;

@end