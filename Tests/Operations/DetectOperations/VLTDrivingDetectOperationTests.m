//
//  VLTDrivingDetectOperationTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 18/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTDrivingDetectOperation.h"
#import <OCMock/OCMock.h>
#import "Velocity.pb.h"
#import "VLTSampleBuilder.h"

@interface VLTDrivingDetectOperationTests : XCTestCase

@end

@implementation VLTDrivingDetectOperationTests

- (void)testOperationExecutionWithEmptyDetectRequest
{
    VLTPBDetectMotionRequest *req = [[VLTPBDetectMotionRequest alloc] init];
    VLTDrivingDetectOperation *op = [[VLTDrivingDetectOperation alloc] initWithMotionRequest:req];

    [op start];
    [op waitUntilFinished];

    XCTAssertFalse(op.speedThreshold == 0.0);
    XCTAssertFalse(op.averageSpeed == 0.0);
    XCTAssertFalse(op.isDriving);
}

@end
