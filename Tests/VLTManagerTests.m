//
//  VLTManagerTests.m
//  Velocity
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTApiClient.h"
#import "VLTManager.h"
#import <OCMock/OCMock.h>

@interface VLTManagerTests : XCTestCase

@property (nonatomic) id apiClientClassMock;

@end

@implementation VLTManagerTests

- (void)setUp {
    [super setUp];

    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientClassMock);
}

- (void)tearDown {
    [self.apiClientClassMock stopMocking];
    [super tearDown];
}


- (void)testmarkGoalAsCompletedSuccess {

    XCTestExpectation *successExpectation = [self expectationWithDescription:@"SuccessBlock"];
    OCMStub([self.apiClientClassMock markGoalAsCompleted:[OCMArg any]
                                                 eventId:[OCMArg any]
                                                 success:[OCMArg invokeBlock]
                                                 failure:[OCMArg any]]).andDo(nil);

    [VLTManager markGoalAsCompleted:@"GOAL_TEST_ID"
                            eventId:@"EVENT_TEST_ID"
                            success:^{
                                [successExpectation fulfill];
                            }
                            failure:^(NSError * _Nonnull error) {

                            }];

    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];
}

- (void)testmarkGoalAsCompletedFailure {
    XCTestExpectation *failureExpectation = [self expectationWithDescription:@"FailureBlock"];
    OCMStub([self.apiClientClassMock markGoalAsCompleted:[OCMArg any]
                                                 eventId:[OCMArg any]
                                                 success:[OCMArg any]
                                                 failure:[OCMArg invokeBlock]]).andDo(nil);
    [VLTManager markGoalAsCompleted:@"GOAL_TEST_ID"
                            eventId:@"EVENT_TEST_ID"
                            success:^{}
                            failure:^(NSError * _Nonnull error) {
                                [failureExpectation fulfill];
                            }];
    [self waitForExpectationsWithTimeout:1 handler:^(NSError * _Nullable error) {}];

}
@end
