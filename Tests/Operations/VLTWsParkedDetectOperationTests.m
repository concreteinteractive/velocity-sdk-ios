//
//  VLTWsParkedDetectOperationTests.m
//  Tests
//
//  Created by Vytautas Galaunia on 26/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTWsParkedDetectOperation.h"
#import "VLTDrivingDetectOperation.h"
#import "VLTWsMotionDetectOperation.h"
#import "VLTMotionDetect.h"
#import "VLTMotionDetectResult.h"
#import <OCMock/OCMock.h>
#import "VLTMacros.h"
#import "VLTCoreMotionActivityTracker.h"

@interface VLTWsParkedDetectOperation (Tests)

- (VLTDrivingDetectOperation *)drivingDetectOperation;
- (id<VLTMotionDetect>)motionDetectOperation;
- (VLTCoreMotionActivityTracker *)activityTracker;

@end



@interface VLTWsParkedDetectOperationTests : XCTestCase

@property (nonatomic, strong) VLTWsApiClient *wsApiClient;
@property (nonatomic, strong) VLTWsParkedDetectOperation *op;

@end

@implementation VLTWsParkedDetectOperationTests

- (void)setUp
{
    [super setUp];

    self.wsApiClient = [[VLTWsApiClient alloc] initWithQueueSize:10];
    NSArray<VLTData *> *datas = [[NSMutableArray alloc] init];
    self.op = [[VLTWsParkedDetectOperation alloc] initWithMotionData:datas wsApiClient:self.wsApiClient];
    self.op = OCMPartialMock(self.op);
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testWithModelDriving
{
    id activityTracker = OCMPartialMock([VLTCoreMotionActivityTracker shared]);
    id recentActivity = OCMClassMock([CMMotionActivity class]);
    OCMStub([recentActivity automotive]).andReturn(NO);
    OCMStub([activityTracker recentActivity]).andReturn(recentActivity);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(YES);

    OCMStub([self.op activityTracker]).andReturn(activityTracker);
    OCMStub([self.op drivingDetectOperation]).andReturn(drivingOp);
    XCTestExpectation *motionDetectExpectation = [self expectationWithDescription:@"block invoked"];
    vlt_weakify(self);
    self.op.onMotionDetect = ^(VLTMotionDetectResult * _Nonnull result) {
        vlt_strongify(self);
        [motionDetectExpectation fulfill];

        XCTAssertTrue(result.isDriving);
        XCTAssertFalse(result.isParked);
        XCTAssertFalse(result.isWalking);
    };

    [self.op start];
    [self waitForExpectations:@[motionDetectExpectation] timeout:0.1];

    [activityTracker stopMocking];
}

- (void)testWithCoreMotionDriving
{
    id activityTracker = OCMPartialMock([VLTCoreMotionActivityTracker shared]);
    id recentActivity = OCMClassMock([CMMotionActivity class]);
    OCMStub([recentActivity automotive]).andReturn(YES);
    OCMStub([activityTracker recentActivity]).andReturn(recentActivity);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(NO);

    OCMStub([self.op activityTracker]).andReturn(activityTracker);
    OCMStub([self.op drivingDetectOperation]).andReturn(drivingOp);
    XCTestExpectation *motionDetectExpectation = [self expectationWithDescription:@"block invoked"];
    vlt_weakify(self);
    self.op.onMotionDetect = ^(VLTMotionDetectResult * _Nonnull result) {
        vlt_strongify(self);
        [motionDetectExpectation fulfill];
        XCTAssertTrue(result.isDriving);
        XCTAssertFalse(result.isParked);
        XCTAssertFalse(result.isWalking);
    };

    [self.op start];
    [self waitForExpectations:@[motionDetectExpectation] timeout:0.1];

    [activityTracker stopMocking];
}

- (void)testNoDrivingButDetectError
{
    id activityTracker = OCMPartialMock([VLTCoreMotionActivityTracker shared]);
    id recentActivity = OCMClassMock([CMMotionActivity class]);
    OCMStub([recentActivity automotive]).andReturn(NO);
    OCMStub([activityTracker recentActivity]).andReturn(recentActivity);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(NO);

    OCMStub([self.op activityTracker]).andReturn(activityTracker);
    OCMStub([self.op drivingDetectOperation]).andReturn(drivingOp);


    VLTWsMotionDetectOperation *motionDetectOp = [[VLTWsMotionDetectOperation alloc] init];
    motionDetectOp = OCMPartialMock(motionDetectOp);
    OCMStub([motionDetectOp start]).andDo(nil);
    OCMStub([motionDetectOp waitUntilFinished]).andDo(nil);
    OCMStub([motionDetectOp error]).andReturn([NSError errorWithDomain:@"TESTS" code:1 userInfo:nil]);

    OCMStub([self.op motionDetectOperation]).andReturn(motionDetectOp);

    XCTestExpectation *motionDetectErrorExpectation = [self expectationWithDescription:@"error block invoked"];
    vlt_weakify(self);
    self.op.onError = ^(NSError * error) {
        vlt_strongify(self);
        [motionDetectErrorExpectation fulfill];
        XCTAssertEqual(1, error.code);
        XCTAssertEqualObjects(@"TESTS", error.domain);
    };

    [self.op start];
    [self waitForExpectations:@[motionDetectErrorExpectation] timeout:0.1];

    [activityTracker stopMocking];
}

- (void)testNotDrivingAndWalkingDetection
{
    id activityTracker = OCMPartialMock([VLTCoreMotionActivityTracker shared]);
    id recentActivity = OCMClassMock([CMMotionActivity class]);
    OCMStub([recentActivity automotive]).andReturn(NO);
    OCMStub([activityTracker recentActivity]).andReturn(recentActivity);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(NO);

    OCMStub([self.op activityTracker]).andReturn(activityTracker);
    OCMStub([self.op drivingDetectOperation]).andReturn(drivingOp);


    VLTWsMotionDetectOperation *motionDetectOp = [[VLTWsMotionDetectOperation alloc] init];
    motionDetectOp = OCMPartialMock(motionDetectOp);
    OCMStub([motionDetectOp start]).andDo(nil);
    OCMStub([motionDetectOp waitUntilFinished]).andDo(nil);
    OCMStub([motionDetectOp result]).andReturn([[VLTMotionDetectResult alloc] initWithWalking:YES driving:NO parked:NO]);

    OCMStub([self.op motionDetectOperation]).andReturn(motionDetectOp);

    XCTestExpectation *motionDetectExpectation = [self expectationWithDescription:@"error block invoked"];
    vlt_weakify(self);
    self.op.onMotionDetect = ^(VLTMotionDetectResult * result) {
        vlt_strongify(self);
        [motionDetectExpectation fulfill];
        XCTAssertTrue(result.isWalking);
        XCTAssertFalse(result.isDriving);
        XCTAssertTrue(result.isParked);
    };

    [self.op start];
    [self waitForExpectations:@[motionDetectExpectation] timeout:0.1];

    [activityTracker stopMocking];
}

- (void)testNotDrivingAndNoWalkingDetection
{
    id activityTracker = OCMPartialMock([VLTCoreMotionActivityTracker shared]);
    id recentActivity = OCMClassMock([CMMotionActivity class]);
    OCMStub([recentActivity automotive]).andReturn(NO);
    OCMStub([activityTracker recentActivity]).andReturn(recentActivity);

    VLTDrivingDetectOperation *drivingOp = [[VLTDrivingDetectOperation alloc] init];
    drivingOp = OCMPartialMock(drivingOp);
    OCMStub([drivingOp start]).andDo(nil);
    OCMStub([drivingOp waitUntilFinished]).andDo(nil);
    OCMStub([drivingOp isDriving]).andReturn(NO);

    OCMStub([self.op activityTracker]).andReturn(activityTracker);
    OCMStub([self.op drivingDetectOperation]).andReturn(drivingOp);


    VLTWsMotionDetectOperation *motionDetectOp = [[VLTWsMotionDetectOperation alloc] init];
    motionDetectOp = OCMPartialMock(motionDetectOp);
    OCMStub([motionDetectOp start]).andDo(nil);
    OCMStub([motionDetectOp waitUntilFinished]).andDo(nil);
    OCMStub([motionDetectOp result]).andReturn([[VLTMotionDetectResult alloc] initWithWalking:NO driving:NO parked:NO]);

    OCMStub([self.op motionDetectOperation]).andReturn(motionDetectOp);

    XCTestExpectation *motionDetectExpectation = [self expectationWithDescription:@"error block invoked"];
    vlt_weakify(self);
    self.op.onMotionDetect = ^(VLTMotionDetectResult * result) {
        vlt_strongify(self);
        [motionDetectExpectation fulfill];
        XCTAssertFalse(result.isWalking);
        XCTAssertFalse(result.isDriving);
        XCTAssertFalse(result.isParked);
    };

    [self.op start];
    [self waitForExpectations:@[motionDetectExpectation] timeout:0.1];

    [activityTracker stopMocking];
}

@end
