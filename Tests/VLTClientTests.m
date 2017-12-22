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
#import "VLTMotionRecorder.h"
#import "VLTData.h"

@import SocketRocket;

@interface VLTClient()
@property (atomic, strong) id<VLTMotionRecorder> recorder;
@end

@interface VLTClient (Tests)

@property (atomic, strong) VLTRecordingConfig *recordingConfig;
@property (atomic, strong) VLTWsApiClient *wsApiClient;

- (void)startRecording;

@end

@interface VLTClientTests : XCTestCase

@property (nonatomic) VLTClient *client;
@property (nonatomic) id wsMock;

@end

@implementation VLTClientTests

- (void)setUp
{
    [super setUp];

    VLTPBHandshakeResponse *handshakeResponse = [[VLTPBHandshakeResponse alloc] init];
    handshakeResponse.sampleSize = 2;
    handshakeResponse.captureInterval = 2;
    handshakeResponse.canDetectMotion = YES;
    handshakeResponse.canLabelMotion = YES;

    self.client = [[VLTClient alloc] init];
    self.client.recordingConfig = [[VLTRecordingConfig alloc] initWithHandshakeResponse:handshakeResponse];
}

- (void)testRecording
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Detect handler invoked"];
    [self.client startRecording];
    id wsMock = OCMPartialMock(self.client.wsApiClient);
    OCMStub([wsMock isOpen]).andReturn(true);

    __block BOOL alreadyFulfilled = NO;
    self.client.operationFatoryHandler = ^NSArray<VLTMotionDataOperation *> *(VLTWsApiClient *wsApiClient, NSArray<VLTData *> * motionData, UInt32 sequenceIndex) {
        VLTHTTPMotionDetectOperation *op = [[VLTHTTPMotionDetectOperation alloc] initWithMotionData:motionData
                                                                              sequenceIndex:sequenceIndex];
        id operationMock = OCMPartialMock(op);
        OCMStub([operationMock processMotionData]).andDo(^(NSInvocation *invocation) {
            op.onMotionDetect([[VLTMotionDetectResult alloc] init]);
        });
        op.onMotionDetect = ^(VLTMotionDetectResult *result) {
            if (!alreadyFulfilled) {
                alreadyFulfilled = YES;
                [expectation fulfill];
            }
        };

        return @[op];
    };

    [self waitForExpectations:@[expectation] timeout:12];
}

- (void)testPushMotionDataWithLabels
{
    self.client.active = YES;

    id apiClientMock = OCMPartialMock([VLTApiClient shared]);
    id apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([apiClientClassMock shared]).andReturn(apiClientMock);
    
    [self stubRecorderWithData:[[VLTData alloc] initWithSensorType:VLTSensorTypeAcc values:@[]]];
    
    XCTestExpectation *vltApiClientExpectation = [self expectationWithDescription:@"VLTApiClient handler invoked"];
    OCMExpect([apiClientMock uploadMotionData:OCMOCK_ANY
                                       labels:OCMOCK_ANY
                                      success:OCMOCK_ANY
                                      failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(void);
        [invocation getArgument:&successBlock atIndex:4];
        successBlock();
        [vltApiClientExpectation fulfill];
    });

    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Success handler invoked"];
    [self.client pushMotionDataWithLabels:@[@"test-motion"]
                                  success:^{
                                      [successExpectation fulfill];
                                  }
                                  failure:^(NSError * _Nullable error) {
                                      NSLog(@"ERROR: %@", error);
                                  }];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

- (void)testPushMotionDataWithLabelsForEmptyData
{
    self.client.active = YES;
    
    id apiClientMock = OCMPartialMock([VLTApiClient shared]);
    id apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([apiClientClassMock shared]).andReturn(apiClientMock);
    
    XCTestExpectation *vltApiClientExpectation = [self expectationWithDescription:@"VLTApiClient handler invoked with nil data"];
    OCMExpect([apiClientMock uploadMotionData:nil
                                       labels:OCMOCK_ANY
                                      success:OCMOCK_ANY
                                      failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(void);
        [invocation getArgument:&successBlock atIndex:4];
        successBlock();
        [vltApiClientExpectation fulfill];
    });
    
    [self stubRecorderWithData:nil];
    
    XCTestExpectation *pushExpectation = [self expectationWithDescription:@"Fail handler invoked"];
    [self.client pushMotionDataWithLabels:@[@"test-motion"]
                                  success:^{
                                      [pushExpectation fulfill];
                                  }
                                  failure:^(NSError * _Nullable error) {}];
    [self waitForExpectationsWithTimeout:5 handler:nil];
}

-(void)stubRecorderWithData:(VLTData *)data
{
    id recorder = [[VLTSensorRecorder alloc] initWithUpdateInterval:5 timeInBuffer:60];
    id recorderMock = OCMPartialMock(recorder);
    OCMStub([[recorderMock ignoringNonObjectArgs] dataForTimeInterval:5]).andReturn(data ? @[data] : @[]);
    self.client.recorder = recorder;
}

@end

