
//
//  VLTLabeledDataUploadOperationTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTApiClient.h"
#import <OCMock/OCMock.h>
#import "VLTLabeledDataUploadOperation.h"

@interface VLTLabeledDataUploadOperationTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;

@end

@implementation VLTLabeledDataUploadOperationTests

- (void)setUp
{
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);
}

- (void)tearDown
{
    [self.apiClientClassMock stopMocking];
    [self.apiClientMock stopMocking];

    [super tearDown];
}

- (void)testOperationExecution
{
    VLTLabeledDataUploadOperation *op;
    NSArray<VLTData *> *motionData = @[];
    XCTestExpectation *successExpectation = [self expectationWithDescription:@"Success handler invoked"];

    OCMExpect([self.apiClientMock uploadMotionData:OCMOCK_ANY
                                            labels:OCMOCK_ANY
                                           success:OCMOCK_ANY
                                           failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(void);
        [invocation getArgument:&successBlock atIndex:4];
        successBlock();
    });

    op = [[VLTLabeledDataUploadOperation alloc] initWithMotionData:motionData labels:@[@"TEST_LABEL"]];
    op.onSuccess = ^{
        [successExpectation fulfill];
    };
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    OCMExpect([self.apiClientMock uploadMotionData:OCMOCK_ANY
                                            labels:OCMOCK_ANY
                                           success:OCMOCK_ANY
                                           failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^errorBlock)(NSError *error);
        [invocation getArgument:&errorBlock atIndex:5];
        errorBlock([NSError errorWithDomain:@"Tests" code:1 userInfo:nil]);
    });
    XCTestExpectation *failureExpectation = [self expectationWithDescription:@"Error handler invoked"];

    op = [[VLTLabeledDataUploadOperation alloc] initWithMotionData:motionData labels:@[@"TEST_LABEL"]];
    op.onError = ^(NSError *error) {
        [failureExpectation fulfill];
    };
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    XCTAssertNotNil(op.error);
    [self waitForExpectationsWithTimeout:2 handler:nil];
}


@end
