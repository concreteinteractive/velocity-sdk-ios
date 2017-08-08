//
//  VLTDetectorTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 08/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTApiClient.h"
#import "VLTRecordingConfig.h"
#import "VLTDetector.h"
#import "VLTDetectResult.h"

@interface VLTDetectorTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;

@end

@implementation VLTDetectorTests

- (void)setUp
{
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);

    VLTRecordingConfig *cfg = [[VLTRecordingConfig alloc] initSampleSize:2 interval:2 detectioMotionOn:true];
    OCMStub([self.apiClientMock getConfigWithIFA:[OCMArg any]
                                         success:[OCMArg any]
                                         failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTRecordingConfig * _Nonnull config);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(cfg);
    });
    OCMStub([self.apiClientMock detect:[OCMArg any]
                               success:[OCMArg any]
                               failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTDetectResult * _Nonnull result);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock([[VLTDetectResult alloc] initWithDictionary:@{
                                                                   VLTDetectResultWalkingKey : @YES,
                                                                   VLTDetectResultDrivingKey : @NO,
                                                                   }]);
    });
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testActive {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Detect handler invoked"];
    [VLTDetector setOnDetectReceivedHandler:^(VLTDetectResult *result) {
        XCTAssert([NSThread isMainThread], @"Handler must be invoked on main thread.");
        [expectation fulfill];
    }];
    [VLTDetector activate];
    [self waitForExpectations:@[expectation] timeout:5];


}

@end
