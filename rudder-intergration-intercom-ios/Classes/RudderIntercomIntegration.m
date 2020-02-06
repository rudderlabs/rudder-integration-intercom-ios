//
//  RudderAdjustIntegration.m
//  FBSnapshotTestCase
//
//  Created by Arnab Pal on 29/10/19.
//

#import "RudderIntercomIntegration.h"
#import "Intercom/Intercom.h"
#import "RudderLogger.h"

@implementation RudderIntercomIntegration


#pragma mark - Initialization

- (instancetype)initWithConfig:(NSDictionary *)config withAnalytics:(nonnull RudderClient *)client  withRudderConfig:(nonnull RudderConfig *)rudderConfig{
    self = [super init];
    if (self) {
        self.config = config;
        self.client = client;
        
        NSString *mobileApiKey = nil;
        NSString *appId = nil;

        if([config objectForKey:@"mobileApiKey"] != nil && [config objectForKey:@"appId"] != nil){
            mobileApiKey = [config objectForKey:@"mobileApiKey"];
            appId = [config objectForKey:@"appId"];
            [Intercom setApiKey:mobileApiKey forAppId:appId];
        }
    }
    return self;
}

- (void)dump:(nonnull RudderMessage *)message {
//    if (self.eventMap == nil) {
//        return;
//    }
    if([message.type isEqualToString:@"identify"]) {
        
        ICMUserAttributes *userAttributes = [ICMUserAttributes new];
        ICMCompany *company = [ICMCompany new];
        
        if (message.userId) {
            [Intercom registerUserWithUserId:message.userId];
             [Intercom registerUserWithUserId:message.userId];
        } else if (message.anonymousId) {
            [Intercom registerUnidentifiedUser];
        }
        
        NSDictionary *traits = message.context.traits;
        if(traits != nil){
            
            for (NSString* trait in traits){
                
                if ([[trait lowercaseString] isEqualToString:@"company"]) {
                    if([message.context.traits[trait] class] != [NSDictionary class]){
//                        [RudderLogger logError: <#(nonnull NSString *)#>];
                    }
                    NSDictionary *companyTraits = message.context.traits[trait];
                    if(companyTraits != nil){
                        for(NSString* field in companyTraits){
                            if([[field lowercaseString] isEqualToString:@"name"]){
                                company.name = companyTraits[field];
                            }else if ([[field lowercaseString] isEqualToString:@"id"]){
                                company.companyId = companyTraits[field];
                            }else{
                                userAttributes.customAttributes = companyTraits[field];
                            }
                        }
                        userAttributes.companies = @[company];
                    }
                }else{
                    if ([[trait lowercaseString] isEqualToString:@"name"]) {
                        userAttributes.name = traits[trait];
                    }
                    else if ([[trait lowercaseString] isEqualToString:@"email"]) {
                        userAttributes.email = traits[trait];
                    }
                    else if ([[trait lowercaseString] isEqualToString:@"phone"]) {
                        userAttributes.phone = traits[trait];
                    }
//                    else if ([[trait lowercaseString] isEqualToString:@"signedUpAt"]) {
//                        userAttributes.name = traits[trait];
//                    }
                    else {
                        userAttributes.customAttributes = traits[trait];
                    };
                }
            }
            [Intercom updateUser:userAttributes];
        }

    }

    if([message.type isEqualToString:@"track"]) {
        
        NSDictionary *eventData = message.properties;
        NSString *eventName = message.event;
        NSMutableDictionary *newPayload;
        
        if(eventName != nil || eventData != nil){
            for (NSString* prop in eventData) {
                newPayload[prop] = eventData[prop];
            }
        };
        [Intercom logEventWithName:eventName metaData: newPayload];
    }
}

- (void)reset {
    [Intercom logout];
}


@end
