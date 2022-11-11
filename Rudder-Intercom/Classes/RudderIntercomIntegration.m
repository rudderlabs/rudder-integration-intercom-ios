//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderIntercomIntegration.h"
#import "Intercom/Intercom.h"

@implementation RudderIntercomIntegration


#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RSClient *)client  withRudderConfig:(nonnull RSConfig *)rudderConfig{
    self = [super init];
    if (self) {        
        if([config objectForKey:@"mobileApiKeyIOS"] != nil && [config objectForKey:@"appId"] != nil){
            NSString *mobileApiKey = [config objectForKey:@"mobileApiKeyIOS"];
            NSString *appId = [config objectForKey:@"appId"];
            dispatch_async(dispatch_get_main_queue(), ^{
                [Intercom setApiKey:mobileApiKey forAppId:appId];
                
                NSMutableDictionary *traits = [client getContext].traits;
                NSString *userId = traits[@"userId"];
                if (userId == nil) {
                    userId = traits[@"id"];
                }
                if (userId != nil) {
                    ICMUserAttributes *userAttributes = [ICMUserAttributes new];
                    userAttributes.userId = userId;
                    [Intercom loginUserWithUserAttributes:userAttributes success:^{
                        [RSLogger logDebug:@"RudderIntercomIntegration: Login only identified users: success"];
                    } failure:^(NSError * _Nonnull error) {
                        [RSLogger logDebug:@"RudderIntercomIntegration: Login only identified users: success"];
                    }];
                } else {
                    [Intercom loginUnidentifiedUserWithSuccess:^{
                        [RSLogger logDebug:@"RudderIntercomIntegration: Login only unidentified users: success"];
                    } failure:^(NSError * _Nonnull error) {
                        [RSLogger logDebug:[NSString stringWithFormat:@"RudderIntercomIntegration: Login only unidentified users. Reason: %@", error.description]];
                    }];
                }
            });
        }
    }
    return self;
}

- (void)dump:(nonnull RSMessage *)message {
    if ([message.type isEqualToString:@"identify"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ICMUserAttributes *userAttributes = [ICMUserAttributes new];
            if (message.userId) {
                userAttributes.userId = message.userId;
                [Intercom loginUserWithUserAttributes:userAttributes success:^{
                    [RSLogger logDebug:@"RudderIntercomIntegration: Login only identified users: success"];
                } failure:^(NSError * _Nonnull error) {
                    [RSLogger logDebug:@"RudderIntercomIntegration: Login only identified users: success"];
                }];
            } else {
                [Intercom loginUnidentifiedUserWithSuccess:^{
                    [RSLogger logDebug:@"RudderIntercomIntegration: Login only unidentified users: success"];
                } failure:^(NSError * _Nonnull error) {
                    [RSLogger logDebug:[NSString stringWithFormat:@"RudderIntercomIntegration: Login only unidentified users: failed. Reason: %@", error.description]];
                }];
            }
            
            NSDictionary *traits = message.context.traits;
            if (traits != nil) {
                for (NSString* trait in traits) {
                    if ([[trait lowercaseString] isEqualToString:@"company"]) {
                        ICMCompany *company = [ICMCompany new];
                        NSDictionary *companyTraits = (NSDictionary*) message.context.traits[trait];
                        if(companyTraits != nil) {
                            for(NSString* field in companyTraits) {
                                if([[field lowercaseString] isEqualToString:@"name"]) {
                                    company.name = companyTraits[field];
                                } else if ([[field lowercaseString] isEqualToString:@"id"]) {
                                    company.companyId = companyTraits[field];
                                }
                            }
                            userAttributes.companies = @[company];
                        }
                    } else if ([[trait lowercaseString] isEqualToString:@"name"]) {
                        userAttributes.name = traits[trait];
                    } else if ([[trait lowercaseString] isEqualToString:@"email"]) {
                        userAttributes.email = traits[trait];
                    } else if ([[trait lowercaseString] isEqualToString:@"phone"]) {
                        userAttributes.phone = traits[trait];
                    } else if ([[trait lowercaseString] isEqualToString:@"createdAt"]) {
                        userAttributes.signedUpAt = traits[trait];
                    };
                }
            }
            if (![self isEmpty:userAttributes]) {
                [Intercom updateUser:userAttributes success:^{
                    [RSLogger logDebug:@"RudderIntercomIntegration: Update user attributes: success"];
                } failure:^(NSError * _Nonnull error) {
                    [RSLogger logDebug:[NSString stringWithFormat:@"RudderIntercomIntegration: Update user attributes: failed. Reason: %@", error.description]];
                }];
            }
        });
    } else if([message.type isEqualToString:@"track"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (message.properties) {
                [Intercom logEventWithName:message.event metaData: message.properties];
            } else {
                [Intercom logEventWithName:message.event];
            }
        });
    }
}

- (BOOL)isEmpty:(ICMUserAttributes *)userAttributes {
    return (userAttributes.name == nil && userAttributes.companies == nil && userAttributes.email == nil && userAttributes.phone == nil);
}

- (void)reset {
    [Intercom logout];
}

- (void)flush {
    
}

@end
