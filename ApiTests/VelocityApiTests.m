//
//  VelocityApiTests.m
//  VelocityApiTests
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTApiClient.h"
#import <OCMock/OCMock.h>
#import "VLTSimpleSample.h"
#import "VLTData.h"
#import "VLTProtobufHelper.h"
#import "Velocity.pbobjc.h"

@interface VLTApiClient ()

- (instancetype)initWithBaseURLPath:(NSString *)url;

@end

@interface VelocityApiTests : XCTestCase

@property (nonatomic) VLTApiClient *apiClient;

@end

@implementation VelocityApiTests

- (void)setUp {
    [super setUp];

    self.apiClient = [[VLTApiClient alloc] initWithBaseURLPath:@"http://127.0.0.1:8080/api/"];
    [self.apiClient setApiToken:@"TEST_API_CLIENT"];
}

- (void)tearDown {
    [super tearDown];
}


- (void)testCapture
{
    VLTSimpleSample *accSample = [[VLTSimpleSample alloc] initWithTimestamp:1 x:1 y:2 z:3];
    VLTSimpleSample *gyroSample = [[VLTSimpleSample alloc] initWithTimestamp:2 x:2 y:3 z:4];
    VLTData *accData = [[VLTData alloc] initWithSensorType:VLTSensorTypeAcc values:@[accSample]];
    VLTData *gyroData = [[VLTData alloc] initWithSensorType:VLTSensorTypeGyro values:@[gyroSample]];

    VLTPBCapture *capture = [VLTProtobufHelper captureFromDatas:@[accData, gyroData]
                                                            ifa:@"RAND-OMIFA"
                                                  sequenceIndex:1
                                                   impressionId:@"RANDOM-IMPRESSION-ID"];

    XCTestExpectation *expectation = [self expectationWithDescription:@"APIResponse"];
    __block NSError *apiError = nil;

    [self.apiClient uploadForTracking:capture success:^{
        [expectation fulfill];
    } failure:^(NSError * _Nonnull error) {
        apiError = error;
    }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(apiError, @"API error should NOT occur");
    }];
}

- (void)testCaptureError
{
    VLTPBCapture *capture = [VLTProtobufHelper captureFromDatas:@[]
                                                            ifa:@"RAND-OMIFA"
                                                  sequenceIndex:1
                                                   impressionId:@"RANDOM-IMPRESSION-ID"];
    XCTestExpectation *expectation = [self expectationWithDescription:@"APIResponseFailure"];
    __block NSError *apiError = nil;

    [self.apiClient uploadForTracking:capture success:^{
    } failure:^(NSError * _Nonnull error) {
        apiError = error;
        [expectation fulfill];
    }];
    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(apiError, @"API error should occur");
    }];
}

- (void)testMarkGoalAsCompleted
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"APIResponse"];
    __block NSError *apiError = nil;
    [self.apiClient markGoalAsCompleted:@"TEST_GAOL_ID"
                                eventId:@"TEST_EVENT_ID"
                                success:^{
                                    [expectation fulfill];
                                }
                                failure:^(NSError * _Nonnull error) {
                                    apiError = error;
                                }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNil(apiError, @"API error should NOT occur");
    }];
}

- (void)testMarkGoalAsCompletedError
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"APIResponseFailure"];
    __block NSError *apiError = nil;
    [self.apiClient markGoalAsCompleted:@""
                                eventId:@"TEST_EVENT_ID"
                                success:^{}
                                failure:^(NSError * _Nonnull error) {
                                    apiError = error;
                                    [expectation fulfill];
                                }];

    [self waitForExpectationsWithTimeout:5 handler:^(NSError * _Nullable error) {
        XCTAssertNotNil(apiError, @"API error should occur");
    }];
}

@end
