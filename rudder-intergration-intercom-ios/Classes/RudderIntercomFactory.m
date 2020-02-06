//
//  RudderAdjustFactory.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderIntercomFactory.h"
#import "RudderIntercomIntegration.h"

@implementation RudderIntercomFactory

static RudderIntercomFactory *sharedInstance;

+ (instancetype)instance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (nonnull NSString *)key {
    return @"Intercom";
}

- (nonnull id<RudderIntegration>)initiate:(nonnull NSDictionary *)config client:(nonnull RudderClient *)client rudderConfig:(nonnull RudderConfig *)rudderConfig {
    return [[RudderIntercomIntegration alloc] initWithConfig:config withAnalytics:client withRudderConfig:rudderConfig];
}


@end
