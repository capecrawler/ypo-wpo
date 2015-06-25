//
//  YPOMember.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPOMember.h"
#import "YPORole.h"
#import "YPOAPIClient.h"


@implementation YPOMember

@dynamic chapterID;
@dynamic firstName;
@dynamic lastName;
@dynamic memberID;
@dynamic name;
@dynamic nickname;
@dynamic profilePicURL;
@dynamic joinedDate;
@dynamic role;


+ (YPOHTTPRequest *)constructRequest {
    YPOHTTPRequest *request = [super constructRequest];
    request.apiPath = @"members.list";
    return request;
}


@end
