//
//  VLTDrivingDetectOperationTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTDrivingDetectOperation.h"
#import <OCMock/OCMock.h>
#import "Velocity.pbobjc.h"
#import "VLTSampleBuilder.h"
#import "VLTData.h"

@interface VLTDrivingDetectOperationTests : XCTestCase

@end

@implementation VLTDrivingDetectOperationTests

- (void)testOperationExecutionWithEmptyDetectRequest
{
    VLTData *gpsData = [[VLTData alloc] initWithSensorType:VLTSensorTypeGPS values:@[]];
    VLTDrivingDetectOperation *op = [[VLTDrivingDetectOperation alloc] initWithMotionData:@[gpsData]];

    [op start];
    [op waitUntilFinished];

    XCTAssertFalse(op.speedThreshold == 0.0);
    XCTAssertFalse(op.averageSpeed == 0.0);
    XCTAssertFalse(op.isDriving);
}

@end
