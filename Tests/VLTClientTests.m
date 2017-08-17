//
//  VLTClientTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "VLTClient.h"
#import "VLTApiClient.h"
#import "VLTRecordingConfig.h"
#import "VLTMotionDetectResult.h"
#import "VLTMacros.h"

@interface VLTClientTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;
@property (nonatomic) VLTClient *client;

@end

@implementation VLTClientTests

- (void)setUp
{
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);

    VLTRecordingConfig *cfg = [[VLTRecordingConfig alloc] initSampleSize:2 interval:2 detectioMotionOn:true];
    OCMStub([self.apiClientMock configWithIFA:[OCMArg any]
                                      success:[OCMArg any]
                                      failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTRecordingConfig *config);
        [invocation getArgument:&successBlock atIndex:3];
        successBlock(cfg);
    });
    OCMStub([self.apiClientMock detect:[OCMArg any]
                               success:[OCMArg any]
                               failure:[OCMArg any]]).andDo(^(NSInvocation *invocation) {
        void (^successBlock)(VLTMotionDetectResult *result);
        [invocation getArgument:&successBlock atIndex:3];

        successBlock([[VLTMotionDetectResult alloc] initWithDictionary:@{
                                                                         VLTMotionDetectResultWalkingKey : @YES,
                                                                         VLTMotionDetectResultDrivingKey : @NO,
                                                                         }]);
    });
}

- (void)testActive
{
    XCTestExpectation *expectation = [self expectationWithDescription:@"Detect handler invoked"];
    self.client = [[VLTClient alloc] init];
    self.client.detectionOn = YES;
    vlt_weakify(self);
    self.client.detectHandler = ^(VLTMotionDetectResult *result) {
        vlt_strongify(self);
        XCTAssert([NSThread isMainThread], @"Handler must be invoked on main thread.");
        [expectation fulfill];
    };
    self.client.active = YES;
    [self waitForExpectations:@[expectation] timeout:5];
}


@end
