//
//  YPORole.m
//  YPO-WPO SG
//
//  Created by Mario Cape on 6/24/15.
//  Copyright (c) 2015 Raketeers. All rights reserved.
//

#import "YPORole.h"
#import "YPOMember.h"


@implementation YPORole

@dynamic roleID;
@dynamic name;
@dynamic member;

- (void)parseDictionary:(NSDictionary *)dictionary {
    [super parseDictionary:dictionary];
    self.roleID = dictionary[@"role_id"];
    self.name   = dictionary[@"name"];
}

+ (YPOHTTPRequest *)constructRequest:(YPOCancellationToken *)cancellationToken {
    YPORoleRequest *request = [[YPORoleRequest alloc] init];
    request.cancellationToken = cancellationToken;
    request.function = @"roles.list";
    return request;
}

@end


@implementation YPORoleRequest

- (void)loadJSONObject:(id)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        NSArray *data = jsonObject[@"data"];
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            for (NSDictionary *raw in data) {
                YPORole *role = [YPORole MR_findFirstByAttribute:@"roleID" withValue:raw[@"role_id"] inContext:localContext];
                if (role == nil) {
                    role = [YPORole MR_createEntityInContext:localContext];
                }
                [role parseDictionary:raw];
            }
        }];
    }
}


- (void)endLoadJSON:(id)jsonObject {
    if ([jsonObject[@"status"] boolValue]) {
        [MagicalRecord saveWithBlockAndWait:^(NSManagedObjectContext *localContext) {
            NSArray *data = jsonObject[@"data"];
            NSArray *roleIDs = [data valueForKey:@"role_id"];
            NSPredicate * predicate = [NSPredicate predicateWithFormat:@"NOT (roleID IN %@)", roleIDs];
            NSArray *orphan = [YPORole MR_findAllWithPredicate:predicate inContext:localContext];
            for (YPORole *role in orphan) {
                [role MR_deleteEntityInContext:localContext];
            }
        }];
    }
}

@end