
//
//  VLTApiWsClientTests.m
//  Tests
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTWsApiClient.h"
#import <SocketRocket/SocketRocket.h>
#import "Velocity.pbobjc.h"

@interface VLTWsApiClient (Tests) <SRWebSocketDelegate>

@property (atomic, strong) SRWebSocket *ws;

- (void)sendData:(NSData *)data success:(VLTWsApiSuccess)success failure:(VLTWsApiFailure)failure;

@end

@interface VLTWsApiClientTests : XCTestCase

@property (nonatomic, strong) VLTWsApiClient *wsApiClient;
@property (nonatomic, strong) id mockWebSocket;

@end

@implementation VLTWsApiClientTests

- (void)setUp
{
    [super setUp];

    self.wsApiClient = [[VLTWsApiClient alloc] initWithQueueSize:10];
    self.mockWebSocket = OCMPartialMock((id)self.wsApiClient.ws);
    OCMStub([self.mockWebSocket readyState]).andReturn(SR_OPEN);
    self.wsApiClient.ws = self.mockWebSocket;
}


- (void)testOpen
{
    id invocation = OCMExpect([self.mockWebSocket open]);

    XCTAssertNil(self.wsApiClient.authToken);
    [self.wsApiClient openWithAuthToken:@"TESTS"];
    OCMVerify(invocation);

    XCTAssertEqual(@"TESTS", self.wsApiClient.authToken);
}

- (void)testHandshakeAndSendData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"handshake test"];

    OCMStub([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]]).andReturn(YES);

    [self.wsApiClient handshakeWithSuccess:^(VLTPBHandshakeResponse * _Nonnull response) {
        XCTAssertEqual(response.sampleSize, 5);
        XCTAssertEqual(response.captureInterval, 10);
        XCTAssertTrue(response.canDetectMotion);
        XCTAssertTrue(response.canLabelMotion);
        [expectation fulfill];
    } failure:^(NSError * _Nonnull error) {
    
    }];

    VLTPBHandshakeResponse *response = [[VLTPBHandshakeResponse alloc] init];
    response.sampleSize = 5;
    response.captureInterval = 10;
    response.canDetectMotion = YES;
    response.canLabelMotion = YES;
    [self.wsApiClient webSocket:self.mockWebSocket didReceiveMessage:[response data]];

    XCTestExpectation *failExpectation = [self expectationWithDescription:@"handshake error test"];


    [self.wsApiClient handshakeWithSuccess:^(VLTPBHandshakeResponse * _Nonnull response) {
    } failure:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, -12321);
        XCTAssertEqual(error.domain, @"TESTS");
        [failExpectation fulfill];
    }];
    NSError *error = [NSError errorWithDomain:@"TESTS" code:-12321 userInfo:nil];
    [self.wsApiClient webSocket:self.mockWebSocket didFailWithError:error];

    [self waitForExpectations:@[expectation, failExpectation] timeout:0.1];
}

- (void)testMotionDetect
{
    OCMStub([self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]]).andReturn(YES);

    XCTestExpectation *expectation = [self expectationWithDescription:@"response received."];

    [self.wsApiClient motionDetect:[[VLTPBRequest alloc] init] success:^(VLTPBResponse * _Nonnull response) {
        XCTAssertEqualObjects(@"TEST MODEL", response.modelPredictionsArray[0].modelName);
        [expectation fulfill];
    } failure:^(NSError * _Nonnull error) {}];

    VLTPBModelPrediction *mp = [[VLTPBModelPrediction alloc] init];
    mp.modelName = @"TEST MODEL";
    VLTPBResponse *response = [[VLTPBResponse alloc] init];
    response.modelPredictionsArray = [@[mp] mutableCopy];
    [self.wsApiClient webSocket:self.mockWebSocket didReceiveMessage:[response data]];

    [self waitForExpectations:@[expectation] timeout:0.1];

    XCTestExpectation *failExpectation = [self expectationWithDescription:@"response received error."];
    
    [self.wsApiClient motionDetect:[[VLTPBRequest alloc] init] success:^(VLTPBResponse * _Nonnull response) {
    } failure:^(NSError * _Nonnull error) {
        XCTAssertEqual(error.code, -12322);
        XCTAssertEqual(error.domain, @"TESTS");
        [failExpectation fulfill];
    }];

    NSError *error = [NSError errorWithDomain:@"TESTS" code:-12322 userInfo:nil];
    [self.wsApiClient webSocket:self.mockWebSocket didFailWithError:error];

    [self waitForExpectations:@[failExpectation] timeout:0.1];
}

- (void)testCaptureUpload
{
    VLTPBRequest * req = [[VLTPBRequest alloc] init];
    req.modelNamesArray = [@[@"TESTS MODEL"] mutableCopy];
    req.sessionId = @"TEST SESSION";


    id invocation = OCMStub([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]])
        .andDo(^(NSInvocation *invocation){

        NSData *data = nil;
        [invocation getArgument:&data atIndex:2];

        NSError *error = nil;
        VLTPBRequest *receivedReq = [[VLTPBRequest alloc] initWithData:data error:&error];
        XCTAssertNotNil(receivedReq);
        XCTAssertEqual(receivedReq.modelNamesArray.count, 0);
        XCTAssertEqualObjects(@"TEST SESSION", receivedReq.sessionId);
        XCTAssertNil(error);
    });

    __block NSError *outError = nil;
    [self.wsApiClient captureUpload:req success:^(VLTPBResponse * _Nonnull response) {

    } failure:^(NSError * _Nonnull error) {
        outError = error;
    }];

    XCTAssertNil(outError);
    OCMVerify(invocation);
}

- (void)testSendData
{
    id invocation = OCMExpect([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY
                                                                    error:[OCMArg setTo:nil]]).andDo(nil);
    NSData *data = [@"THIS IS DATA" dataUsingEncoding:NSUTF8StringEncoding];
    [self.wsApiClient sendData:data success:^(NSData *_Nonnull data) {} failure:^(NSError *_Nonnull error) {}];
    OCMVerify(invocation);
}

- (VLTPBResponse *)emptyResponse
{
    VLTPBResponse *response = [[VLTPBResponse alloc] init];
    response.modelPredictionsArray = [@[] mutableCopy];

    return response;
}

@end
