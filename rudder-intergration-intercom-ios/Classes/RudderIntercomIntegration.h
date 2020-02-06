//
//  RudderAdjustIntegration.h
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import <Foundation/Foundation.h>
#import <RudderSDKCore/RudderIntegration.h>
#import <RudderSDKCore/RudderClient.h>
#import <RudderSDKCore/RudderConfig.h>
#import "RudderIntegration.h"
#import "RudderClient.h"
#import "RudderLogger.h"
@import Intercom;

NS_ASSUME_NONNULL_BEGIN

@interface RudderIntercomIntegration : NSObject<RudderIntegration>

@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) RudderClient *client;
@property (nonatomic, strong) NSMutableDictionary<NSString*, NSString*>* eventMap;

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(RudderClient *)client withRudderConfig:(RudderConfig*) rudderConfig;

@end

NS_ASSUME_NONNULL_END
