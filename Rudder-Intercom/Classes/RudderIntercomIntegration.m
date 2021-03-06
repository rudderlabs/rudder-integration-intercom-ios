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
            [Intercom setApiKey:mobileApiKey forAppId:appId];
            
            NSMutableDictionary *traits = [client getContext].traits;
            NSString *userId = traits[@"userId"];
            if (userId == nil) {
                userId = traits[@"id"];
            }
            if (userId != nil) {
                [Intercom registerUserWithUserId:userId];
            } else {
                [Intercom registerUnidentifiedUser];
            }
        }
    }
    return self;
}

- (void)dump:(nonnull RSMessage *)message {
    if ([message.type isEqualToString:@"identify"]) {
        ICMUserAttributes *userAttributes = [ICMUserAttributes new];
        
        if (message.userId) {
            [Intercom registerUserWithUserId:message.userId];
        } else {
            [Intercom registerUnidentifiedUser];
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
                    userAttributes.name = traits[trait];
                };
            }
        }
        [Intercom updateUser:userAttributes];
    } else if([message.type isEqualToString:@"track"]) {
        if (message.properties) {
            [Intercom logEventWithName:message.event metaData: message.properties];
        } else {
            [Intercom logEventWithName:message.event];
        }
        
    }
}

- (void)reset {
    [Intercom logout];
}

@end
