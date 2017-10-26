//
//  VLTWsCaptureUploadOperationTests.m
//  Tests
//
//  Created by Vytautas Galaunia on 26/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTWsCaptureUploadOperation.h"
#import <OCMock/OCMock.h>
#import "VLTMacros.h"
#import "Velocity.pbobjc.h"

@interface VLTWsCaptureUploadOperationTests : XCTestCase

@property (nonatomic, strong) VLTWsCaptureUploadOperation *op;
@property (nonatomic, strong) id wsApiClientMock;

@end

@implementation VLTWsCaptureUploadOperationTests

- (void)setUp
{
    [super setUp];

    self.wsApiClientMock = OCMPartialMock([[VLTWsApiClient alloc] initWithQueueSize:10]);

    NSArray<VLTData *> *datas = [[NSMutableArray alloc] init];
    self.op = [[VLTWsCaptureUploadOperation alloc] initWithMotionData:datas wsApiClient:self.wsApiClientMock];
}

- (void)testSuccess
{
    OCMStub([self.wsApiClientMock captureUpload:OCMOCK_ANY error:[OCMArg setTo:nil]]).andDo(nil);

    XCTestExpectation *expectation = [self expectationWithDescription:@"block invoked"];
    self.op.onSuccess = ^(NSUInteger bytesSent) {
        [expectation fulfill];
    };
    [self.op start];
    [self waitForExpectations:@[expectation] timeout:0.1];
}

- (void)testFailure
{
    OCMStub([self.wsApiClientMock captureUpload:OCMOCK_ANY
                                          error:[OCMArg setTo:[NSError errorWithDomain:@"TESTS" code:3 userInfo:nil]]])
    .andDo(nil);

    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"block invoked"];
    self.op.onError = ^(NSUInteger bytesSent, NSError *error) {
        [errorExpectation fulfill];
    };

    [self.op start];
    [self waitForExpectations:@[errorExpectation] timeout:0.1];
}

@end
