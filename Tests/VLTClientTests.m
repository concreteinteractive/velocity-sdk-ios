//
//  VLTClientTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTClient.h"
#import "VLTApiClient.h"
#import "VLTRecordingConfig.h"
#import "VLTMotionDetectResult.h"
#import "VLTMacros.h"
#import "VLTData.h"
#import "VLTHTTPMotionDetectOperation.h"
#import "Velocity.pbobjc.h"
#import "VLTWsApiClient.h"

@import SocketRocket;

@interface VLTWsApiClient (Tests) <SRWebSocketDelegate>

@property (atomic, strong) SRWebSocket *ws;

@end

@interface VLTClient (Tests)

@property (atomic, strong) VLTWsApiClient *wsApiClient;

@end

@interface VLTClientTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;
@property (nonatomic) id wsMock;
@property (nonatomic) VLTClient *client;

@end

@implementation VLTClientTests

- (void)setUp
{
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);

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

    self.client = [[VLTClient alloc] init];
    [self.client setAuthToken:@"TESTS"];


    self.client.wsApiClient = OCMPartialMock(self.client.wsApiClient);
    self.wsMock = OCMPartialMock(self.client.wsApiClient.ws);
    OCMStub([self.wsMock open]).andDo(^(NSInvocation *invocation){
        [self.client.wsApiClient webSocketDidOpen:self.wsMock];
    });
    OCMStub([self.client.wsApiClient handshakeWithSuccess:[OCMArg any]
                                                  failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTPBHandshakeResponse *response);
        [invocation getArgument:&successBlock atIndex:2];

        VLTPBHandshakeResponse *handshakeResponse = [[VLTPBHandshakeResponse alloc] init];
        handshakeResponse.sampleSize = 2;
        handshakeResponse.captureInterval = 2;
        handshakeResponse.canDetectMotion = YES;
        handshakeResponse.canLabelMotion = YES;
        successBlock(handshakeResponse);
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
    self.client.active = YES;

    vlt_weakify(self);
    __block BOOL alreadyFulfilled = NO;
    self.client.operationFatoryHandler = ^NSArray<VLTMotionDataOperation *> *(VLTWsApiClient *wsApiClient, NSArray<VLTData *> * motionData, UInt32 sequenceIndex) {
        VLTHTTPMotionDetectOperation *op = [[VLTHTTPMotionDetectOperation alloc] initWithMotionData:motionData
                                                                              sequenceIndex:sequenceIndex];
        op.onMotionDetect = ^(VLTMotionDetectResult *result) {
            vlt_strongify(self);
            XCTAssert([NSThread isMainThread], @"Handler must be invoked on main thread.");

            if (!alreadyFulfilled) {
                alreadyFulfilled = YES;
                [expectation fulfill];
            }
        };

        return @[op];
    };

    [self waitForExpectations:@[expectation] timeout:5];
}

- (void)testPushMotionDataWithLabels
{
    OCMExpect([self.apiClientMock uploadMotionData:OCMOCK_ANY
                                            labels:OCMOCK_ANY
                                           success:OCMOCK_ANY
                                           failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(void);
        [invocation getArgument:&successBlock atIndex:4];
        successBlock();
    });

    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Success handler invoked"];

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
