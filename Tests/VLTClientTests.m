//
//  VLTClientTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTClient.h"
#import "VLTApiClient.h"
#import "VLTRecordingConfig.h"
#import "VLTMotionDetectResult.h"
#import "VLTMacros.h"
#import "VLTData.h"

@interface VLTClientTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;
@property (nonatomic) VLTClient *client;

@end

@implementation VLTClientTests

- (void)setUp
{
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);

    VLTRecordingConfig *cfg = [[VLTRecordingConfig alloc] initSampleSize:2
                                                                interval:2
                                                        detectioMotionOn:YES
                                                       pushLabeledDataOn:YES];
    OCMStub([self.apiClientMock configWithIFA:[OCMArg any]
                                      success:[OCMArg any]
                                      failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTRecordingConfig *config);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(cfg);
    });
    OCMStub([self.apiClientMock detect:[OCMArg any]
                               success:[OCMArg any]
                               failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTMotionDetectResult *result);
        [invocation getArgument:&successBlock atIndex:3];

        successBlock([[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                         VLTMotionDetectResultWalkingKey : @YES,
                                                                         VLTMotionDetectResultDrivingKey : @NO,
                                                                         }]);
    });
}

- (void)tearDown
{
    [self.apiClientClassMock stopMocking];
    [self.apiClientMock stopMocking];

    [super tearDown];
}

- (void)testActive
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Detect handler invoked"];
    self.client = [[VLTClient alloc] init];
    self.client.detectionOn = YES;
    vlt_weakify(self);

    __block BOOL alreadyFulfilled = NO;
    self.client.detectHandler = ^(VLTMotionDetectResult *result) {
        vlt_strongify(self);
        XCTAssert([NSThread isMainThread], @"Handler must be invoked on main thread.");

        if (!alreadyFulfilled) {
            alreadyFulfilled = YES;
            [expectation fulfill];
        }
    };
    self.client.active = YES;
    [self waitForExpectations:@[expectation] timeout:5];
}

- (void)testPushMotionDataWithLabels
{
    OCMExpect([self.apiClientMock uploadMotionData:OCMOCK_ANY
                                            labels:OCMOCK_ANY
                                           success:OCMOCK_ANY
                                           failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)();
        [invocation getArgument:&successBlock atIndex:4];
        successBlock();
    });

    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Success handler invoked"];

    self.client = [[VLTClient alloc] init];
    self.client.active = YES;
    [self.client pushMotionDataWithLabels:@[@"test-motion"]
                                  success:^{
                                      [successExpectation fulfill];
                                  }
                                  failure:^(NSError * _Nullable error) {}];

    OCMVerifyAll(self.apiClientClassMock);
    [self waitForExpectationsWithTimeout:5 handler:nil];
}


@end
