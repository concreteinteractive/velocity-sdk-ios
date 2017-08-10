//
//  VLTGPSSensorRecorderTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 10/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTGPSSensorRecorder.h"
#import <CoreLocation/CoreLocation.h>
#import "VLTGPS.h"

@interface VLTGPSSensorRecorderTests : XCTestCase

@property (nonatomic, strong) VLTGPSSensorRecorder *gpsRecorder;

@end

@implementation VLTGPSSensorRecorderTests

- (void)setUp {
    [super setUp];

    self.gpsRecorder = [[VLTGPSSensorRecorder alloc] initWithUpdateInterval:0.1 timeInBuffer:1];
}

- (void)tearDown {
    self.gpsRecorder = nil;
    [super tearDown];
}

- (void)testGpsRecorder {
    CLLocationManager *manager = [[CLLocationManager alloc] init];
    CLLocation *location = [[CLLocation alloc] initWithCoordinate:CLLocationCoordinate2DMake(10, 10)
                                                         altitude:100
                                               horizontalAccuracy:1
                                                 verticalAccuracy:1
                                                           course:2
                                                            speed:60
                                                        timestamp:[NSDate date]];
    [VLTGPS locationManager:manager didUpdateLocations:@[location]];
    XCTAssertEqual(self.gpsRecorder.availableTimeInBuffer, DBL_MAX);
    XCTAssertEqual([self.gpsRecorder dataForTimeInterval:10].count, 1);
}

@end
