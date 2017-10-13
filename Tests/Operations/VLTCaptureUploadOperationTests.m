//
//  VLTCaptureUploadOperationTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 18/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTApiClient.h"
#import "VLTCaptureUploadOperation.h"

@interface VLTCaptureUploadOperationTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;

@end

@implementation VLTCaptureUploadOperationTests

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
    VLTCaptureUploadOperation *op;

    OCMExpect([self.apiClientMock uploadForTracking:OCMOCK_ANY
                                            success:OCMOCK_ANY
                                            failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(NSUInteger bytesCount);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(20);
    });
    op = [[VLTCaptureUploadOperation alloc] initWithMotionData:@[] sequenceIndex:1];
    XCTestExpectation *expectation = [self expectationWithDescription:@"Error handler invoked"];
    
    op.onSuccess = ^(NSUInteger bytesCount) {
        [expectation fulfill];
    };
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    OCMExpect([self.apiClientMock uploadForTracking:OCMOCK_ANY
                                            success:OCMOCK_ANY
                                            failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^errorBlock)(NSUInteger bytesCount, NSError *error);
        [invocation getArgument:&errorBlock atIndex:4];
        errorBlock(20, [NSError errorWithDomain:@"Tests" code:1 userInfo:nil]);
    });
    XCTestExpectation *errorExpectation = [self expectationWithDescription:@"Error handler invoked"];

    op = [[VLTCaptureUploadOperation alloc] initWithMotionData:@[] sequenceIndex:1];
    op.onError = ^(NSUInteger bytesCount, NSError *error) {
        [errorExpectation fulfill];
    };
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    XCTAssertNotNil(op.error);

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
