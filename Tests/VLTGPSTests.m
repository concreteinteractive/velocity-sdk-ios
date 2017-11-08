//
//  VLTGPSTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTGPS.h"
#import <CoreLocation/CoreLocation.h>

@interface VLTGPSTests : XCTestCase

@end

@implementation VLTGPSTests

- (void)testSetEnabled {
    [VLTGPS setEnabled:YES];
    XCTAssertTrue([VLTGPS isEnabled]);

    [VLTGPS setEnabled:NO];
    XCTAssertFalse([VLTGPS isEnabled]);
}

- (void)testDidUpdateLocations {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:10 longitude:10];

    [self expectationForNotification:VLTGPSLocationUpdateNotification
                              object:[VLTGPS class]
                             handler:^BOOL(NSNotification * _Nonnull notification) {
                                 NSArray<CLLocation *> *locations = notification.userInfo[VLTGPSLocationsKey];
                                 XCTAssertEqual(locations.count, 1, @"locations should contain 1 item");
                                 return YES;
                             }];
    [VLTGPS locationManager:manager didUpdateLocations:@[location]];
    [self waitForExpectationsWithTimeout:0.1 handler:nil];
}

@end
