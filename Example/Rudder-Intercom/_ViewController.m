//
//  _ViewController.m
//  Rudder-Intercom
//
//  Created by arnab on 05/30/2020.
//  Copyright (c) 2020 arnab. All rights reserved.
//

#import "_ViewController.h"
#import <Rudder/Rudder.h>

@interface _ViewController ()

@end

@implementation _ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[RSClient sharedInstance] identify:@"sample_user_id_ios" traits:@{
        @"name" : @"Test Name",
        @"email" : @"test@rudderstack.com",
        @"phone" : @"9876543210",
        @"createdAt" : @"2020-09-09T09:00:00.000Z",
        @"description" : @"Test User",
        @"company": @{
                @"name" : @"Test Company Name",
                @"id": @"test_company_id"
        }
    }];
    [[RSClient sharedInstance] track:@"simple_track_event_ios"];
    [[RSClient sharedInstance] track:@"simple_track_props_ios" properties:@{
        @"key1" : @"value1",
        @"key2" : @"value2"
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
