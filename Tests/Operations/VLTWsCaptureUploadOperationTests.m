//
//  VLTWsCaptureUploadOperationTests.m
//  Tests
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
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
    __block VLTPBResponse *response = [self emptyResponse];
    
    OCMStub([self.wsApiClientMock captureUpload:OCMOCK_ANY
                                        success:OCMOCK_ANY
                                        failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        VLTWsApiRequestSuccess successBlock;
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(response);
    });

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
                                        success:OCMOCK_ANY
                                        failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation){
        VLTWsApiFailure failureBlock;
        [invocation getArgument:&failureBlock atIndex:4];
        failureBlock([NSError errorWithDomain:@"TESTS" code:2 userInfo:nil]);
    });

    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"block invoked"];
    self.op.onError = ^(NSUInteger bytesSent, NSError *error) {
        [errorExpectation fulfill];
    };

    [self.op start];
    [self waitForExpectations:@[errorExpectation] timeout:0.1];

    XCTAssertNotNil(self.op.error);
    XCTAssertEqual(2, self.op.error.code);
    XCTAssertEqualObjects(@"TESTS", [self.op.error domain]);
}

- (VLTPBResponse *)emptyResponse
{
    VLTPBResponse *response = [[VLTPBResponse alloc] init];
    response.modelPredictionsArray = [@[] mutableCopy];

    return response;
}

@end
