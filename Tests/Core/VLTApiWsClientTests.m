
//
//  VLTApiWsClientTests.m
//  Tests
//
//  Created by Vytautas Galaunia on 24/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <Quick/Quick.h>
#import "VLTWsApiClient.h"
#import <SocketRocket/SocketRocket.h>
#import "Velocity.pbobjc.h"

@interface VLTWsApiClient (Tests) <SRWebSocketDelegate>

@property (atomic, strong) SRWebSocket *ws;

@end

@interface VLTApiWsClientTests : XCTestCase

@property (nonatomic, strong) VLTWsApiClient *wsApiClient;
@property (nonatomic, strong) id mockWebSocket;

@end

@implementation VLTApiWsClientTests

- (void)setUp
{
    [super setUp];

    self.wsApiClient = [[VLTWsApiClient alloc] initWithUrl:[NSURL URLWithString:@"http://www.example.com"]
                                                 authToken:@"TESTS-TOKEN"
                                                 queueSize:10];
    self.mockWebSocket = OCMPartialMock((id)self.wsApiClient.ws);
    self.wsApiClient.ws = self.mockWebSocket;
}

- (void)testOpen
{
    id invocation = OCMExpect([self.mockWebSocket open]);
    [self.wsApiClient open];
    OCMVerify(invocation);
}

- (void)testHandshakeAndSendData
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"handshake test"];

    OCMStub([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]]).andDo(nil);

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
    OCMStub([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]]).andDo(nil);

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

- (void)testSendData
{
    id invocation = OCMExpect([(SRWebSocket *)self.mockWebSocket sendData:OCMOCK_ANY error:[OCMArg setTo:nil]]).andDo(nil);
    NSData *data = [@"THIS IS DATA" dataUsingEncoding:NSUTF8StringEncoding];
    [self.wsApiClient sendData:data error:nil];
    OCMVerify(invocation);
}


@end
