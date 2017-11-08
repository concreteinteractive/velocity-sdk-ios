//
//  VLTParkedDetectionOperationTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTDrivingDetectOperation.h"
#import "VLTHTTPMotionDetectOperation.h"
#import "VLTParkedDetectOperation.h"
#import "VLTData.h"
#import "VLTMotionDetectResult.h"
#import <OCMock/OCMock.h>

@interface VLTParkedDetectOperation (Tests)

- (VLTDrivingDetectOperation *)drivingDetectOperation;
- (VLTHTTPMotionDetectOperation *)motionDetectOperation;

@end

@interface VLTParkedDetectionOperationTests : XCTestCase

@property (nonatomic, strong) VLTParkedDetectOperation *operation;

@end

@implementation VLTParkedDetectionOperationTests

- (void)setUp
{
    [super setUp];

    VLTData *gpsData = [[VLTData alloc] initWithSensorType:VLTSensorTypeGPS values:@[]];
    self.operation = [[VLTParkedDetectOperation alloc] initWithMotionData:@[gpsData] sequenceIndex:1];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testOperationExecutionWithIsDriving
{
    VLTParkedDetectOperation *mock = OCMPartialMock(self.operation);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(YES);

    OCMStub([mock drivingDetectOperation]).andReturn(drivingOp);

    XCTestExpectation *onMotionDetectInvoked = [self expectationWithDescription:@"Invoke onMotionDetect block"];

    [mock setOnMotionDetect:^(VLTMotionDetectResult *result){
        XCTAssertTrue(result.isDriving);
        XCTAssertFalse(result.isParked);
        XCTAssertFalse(result.isWalking);
        [onMotionDetectInvoked fulfill];
    }];

    [mock start];
    [mock waitUntilFinished];

    [self waitForExpectationsWithTimeout:3 handler:nil];
}

- (void)testOperationExecutionNotDriving
{
    VLTParkedDetectOperation *mock = OCMPartialMock(self.operation);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(NO);
    OCMStub([mock drivingDetectOperation]).andReturn(drivingOp);


    VLTMotionDetectResult *result = [[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                                        VLTMotionDetectResultDrivingKey: @NO,
                                                                                        VLTMotionDetectResultParkedKey: @NO,
                                                                                        VLTMotionDetectResultWalkingKey: @YES,
                                                                                        }];

    VLTHTTPMotionDetectOperation *detectOp = [[VLTHTTPMotionDetectOperation alloc] init];
    detectOp = OCMPartialMock(detectOp);
    OCMStub([detectOp start]).andDo(nil);
    OCMStub([detectOp waitUntilFinished]).andDo(nil);
    OCMStub([detectOp result]).andReturn(result);
    OCMStub([mock motionDetectOperation]).andReturn(detectOp);

    XCTestExpectation *onMotionDetectInvoked = [self expectationWithDescription:@"Invoke onMotionDetect block"];
    [mock setOnMotionDetect:^(VLTMotionDetectResult *result){
        XCTAssertFalse(result.isDriving);
        XCTAssertTrue(result.isParked);
        XCTAssertTrue(result.isWalking);
        [onMotionDetectInvoked fulfill];
    }];

    [mock start];
    [mock waitUntilFinished];

    [self waitForExpectationsWithTimeout:3 handler:nil];
}


@end
