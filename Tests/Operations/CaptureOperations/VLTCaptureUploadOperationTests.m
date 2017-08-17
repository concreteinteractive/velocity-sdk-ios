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
    [super tearDown];

    [self.apiClientClassMock stopMocking];
    [self.apiClientMock stopMocking];
}

- (void)testOperationExecution
{
    VLTCaptureUploadOperation *op;

    OCMExpect([self.apiClientMock uploadForTracking:OCMOCK_ANY
                                            success:OCMOCK_ANY
                                            failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)();
        [invocation getArgument:&successBlock atIndex:3];
        successBlock();
    });
    op = [[VLTCaptureUploadOperation alloc] init];
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    OCMExpect([self.apiClientMock uploadForTracking:OCMOCK_ANY
                                            success:OCMOCK_ANY
                                            failure:OCMOCK_ANY]).andDo(^(NSInvocation *invocation) {
        void (^errorBlock)(NSError *error);
        [invocation getArgument:&errorBlock atIndex:4];
        errorBlock([NSError errorWithDomain:@"Tests" code:1 userInfo:nil]);
    });
    XCTestExpectation *expectation = [self expectationWithDescription:@"Error handler invoked"];

    op = [[VLTCaptureUploadOperation alloc] init];
    op.onError = ^(NSError *error) {
        [expectation fulfill];
    };
    [op start];
    [op waitUntilFinished];
    OCMVerifyAll(self.apiClientClassMock);

    XCTAssertNotNil(op.error);

    [self waitForExpectationsWithTimeout:2 handler:nil];
}

@end
