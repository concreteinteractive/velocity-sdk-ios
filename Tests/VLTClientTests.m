////
////  VLTClientTests.m
////  VelocitySDK
////
////  
////  Copyright © 2017 VLCTY, Inc. All rights reserved.
////
//
//#import <XCTest/XCTest.h>
//#import <OCMock/OCMock.h>
//#import "VLTClient.h"
//#import "VLTApiClient.h"
//#import "VLTRecordingConfig.h"
//#import "VLTMotionDetectResult.h"
//#import "VLTMacros.h"
//#import "VLTData.h"
//#import "VLTHTTPMotionDetectOperation.h"
//#import "Velocity.pbobjc.h"
//#import "VLTWsApiClient.h"
//
//@import SocketRocket;
//
//
//@interface VLTClient (Tests)
//
//@property (atomic, strong) VLTRecordingConfig *recordingConfig;
//
//- (void)startRecording;
//
//@end
//
//@interface VLTClientTests : XCTestCase
//
//@property (nonatomic) VLTClient *client;
//@property (nonatomic) id wsMock;
//
//@end
//
//@implementation VLTClientTests
//
//- (void)setUp
//{
//    [super setUp];
//
//    VLTPBHandshakeResponse *handshakeResponse = [[VLTPBHandshakeResponse alloc] init];
//    handshakeResponse.sampleSize = 2;
//    handshakeResponse.captureInterval = 2;
//    handshakeResponse.canDetectMotion = YES;
//    handshakeResponse.canLabelMotion = YES;
//
//    self.client = [[VLTClient alloc] init];
//    self.client.recordingConfig = [[VLTRecordingConfig alloc] initWithHandshakeResponse:handshakeResponse];
//}
//
//- (void)testRecording
//{
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Detect handler invoked"];
//    [self.client startRecording];
//
//    vlt_weakify(self);
//    __block BOOL alreadyFulfilled = NO;
//    self.client.operationFatoryHandler = ^NSArray<VLTMotionDataOperation *> *(VLTWsApiClient *wsApiClient, NSArray<VLTData *> * motionData, UInt32 sequenceIndex) {
//        VLTHTTPMotionDetectOperation *op = [[VLTHTTPMotionDetectOperation alloc] initWithMotionData:motionData
//                                                                              sequenceIndex:sequenceIndex];
//        op.onMotionDetect = ^(VLTMotionDetectResult *result) {
//            vlt_strongify(self);
//            XCTAssert([NSThread isMainThread], @"Handler must be invoked on main thread.");
//
//            if (!alreadyFulfilled) {
//                alreadyFulfilled = YES;
//                [expectation fulfill];
//            }
//        };
//
//        return @[op];
//    };
//
//    [self waitForExpectations:@[expectation] timeout:10];
//}
//
//- (void)testPushMotionDataWithLabels
//{
//    self.client.active = YES;
//
//    id apiClientMock = OCMPartialMock([VLTApiClient shared]);
//    id apiClientClassMock = OCMClassMock([VLTApiClient class]);
//    OCMStub([apiClientClassMock shared]).andReturn(apiClientMock);
//
//    OCMExpect([apiClientMock uploadMotionData:OCMOCK_ANY
//                                       labels:OCMOCK_ANY
//                                      success:OCMOCK_ANY
//                                      failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
//        void (^successBlock)(void);
//        [invocation getArgument:&successBlock atIndex:4];
//        successBlock();
//    });
//
//    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Success handler invoked"];
//    
//    [self.client pushMotionDataWithLabels:@[@"test-motion"]
//                                  success:^{
//                                      [successExpectation fulfill];
//                                  }
//                                  failure:^(NSError * _Nullable error) {
//                                      NSLog(@"ERROR: %@", error);
//                                  }];
//
//    OCMVerifyAll(apiClientMock);
//    [self waitForExpectationsWithTimeout:5 handler:nil];
//}
//
//
//@end

