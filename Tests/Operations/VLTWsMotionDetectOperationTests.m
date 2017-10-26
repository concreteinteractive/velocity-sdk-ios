//
//  VLTWsMotionDetectOperationTests.m
//  Tests
//
//  Created by Vytautas Galaunia on 26/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTWsMotionDetectOperation.h"
#import "VLTWsApiClient.h"
#import <OCMock/OCMock.h>
#import "VLTMacros.h"
#import "Velocity.pbobjc.h"
#import "VLTMotionDetectResult.h"

@interface VLTWsMotionDetectOperationTests : XCTestCase

@property (nonatomic, strong) VLTWsMotionDetectOperation *op;
@property (nonatomic, strong) id wsApiClientMock;

@end

@implementation VLTWsMotionDetectOperationTests

- (void)setUp
{
    [super setUp];

    self.wsApiClientMock = OCMPartialMock([[VLTWsApiClient alloc] initWithQueueSize:10]);

    NSArray<VLTData *> *datas = [[NSMutableArray alloc] init];
    self.op = [[VLTWsMotionDetectOperation alloc] initWithMotionData:datas wsApiClient:self.wsApiClientMock];
}

- (void)testError
{
    OCMStub([self.wsApiClientMock motionDetect:OCMOCK_ANY
                                       success:OCMOCK_ANY
                                       failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        void (^errorBlock)(NSError * error);
        [invocation getArgument:&errorBlock atIndex:4];
        errorBlock([NSError errorWithDomain:@"TESTS" code:2 userInfo:nil]);
    });


    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"block invoked"];

    self.op.onError = ^(NSError * error) {
        [errorExpectation fulfill];
    };

    [self.op start];
    [self.op waitUntilFinished];

    XCTAssertNil(self.op.result);
    XCTAssertNotNil(self.op.error);
    XCTAssertEqual(2, self.op.error.code);
    XCTAssertEqualObjects(@"TESTS", [self.op.error domain]);

    [self waitForExpectations:@[errorExpectation] timeout:0.1];
}

- (void)testSuccessWalking
{
    __block VLTPBResponse *response = [self walkingResponse];

    OCMStub([self.wsApiClientMock motionDetect:OCMOCK_ANY
                                       success:OCMOCK_ANY
                                       failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        void (^successBlock)(VLTPBResponse * response);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(response);
    });


    XCTestExpectation *expectation = [self expectationWithDescription:@"block invoked"];

    self.op.onMotionDetect = ^(VLTMotionDetectResult * result) {
        [expectation fulfill];
    };

    [self.op start];
    [self.op waitUntilFinished];

    XCTAssertNotNil(self.op.result);
    XCTAssertTrue(self.op.result.isWalking);
    XCTAssertNil(self.op.error);

    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (void)testSuccessNotWalking
{
    __block VLTPBResponse *response = [self notWalkingResponse];

    OCMStub([self.wsApiClientMock motionDetect:OCMOCK_ANY
                                       success:OCMOCK_ANY
                                       failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        void (^successBlock)(VLTPBResponse * response);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(response);
    });


    XCTestExpectation *expectation = [self expectationWithDescription:@"block invoked"];

    self.op.onMotionDetect = ^(VLTMotionDetectResult * result) {
        [expectation fulfill];
    };

    [self.op start];
    [self.op waitUntilFinished];

    XCTAssertNotNil(self.op.result);
    XCTAssertFalse(self.op.result.isWalking);
    XCTAssertNil(self.op.error);

    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (VLTPBResponse *)notWalkingResponse
{
    VLTPBPrediction *pWalking = [[VLTPBPrediction alloc] init];
    pWalking.name = @"Not walking";
    pWalking.confidence = 99;
    pWalking.timestamp = [NSDate date].timeIntervalSince1970;


    VLTPBModelPrediction *mp = [[VLTPBModelPrediction alloc] init];
    mp.modelName = @"Parking Walking Temporal";
    mp.predictionsArray = [@[pWalking] mutableCopy];

    VLTPBResponse *response = [[VLTPBResponse alloc] init];
    response.modelPredictionsArray = [@[mp] mutableCopy];

    return response;
}

- (VLTPBResponse *)walkingResponse
{
    VLTPBPrediction *pWalking = [[VLTPBPrediction alloc] init];
    pWalking.name = @"Walking";
    pWalking.confidence = 99;
    pWalking.timestamp = [NSDate date].timeIntervalSince1970;


    VLTPBModelPrediction *mp = [[VLTPBModelPrediction alloc] init];
    mp.modelName = @"Parking Walking Temporal";
    mp.predictionsArray = [@[pWalking] mutableCopy];

    VLTPBResponse *response = [[VLTPBResponse alloc] init];
    response.modelPredictionsArray = [@[mp] mutableCopy];

    return response;
}

@end
