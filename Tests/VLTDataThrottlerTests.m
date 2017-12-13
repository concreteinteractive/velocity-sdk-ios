//
//  VLTDataThrottlerTests.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import <AFNetworking/AFNetworkReachabilityManager.h>
#import "VLTDataThrottler.h"

@interface VLTDataThrottlerTests : XCTestCase
@property (nonatomic) id reachability;
@property (nonatomic) VLTDataThrottler *throttler;

@end

@implementation VLTDataThrottlerTests

- (void)setUp
{
    [super setUp];
    [[NSUserDefaults standardUserDefaults] setObject:nil forKey:@"VLTDataThrottlerKey"];
    self.reachability = OCMPartialMock([AFNetworkReachabilityManager manager]);
    self.throttler = [[VLTDataThrottler alloc] initWithLimit:1000 reachabilityManager:self.reachability];
}

- (void)testShouldThrottleWhenUsingCellular
{
    OCMStub([self.reachability isReachableViaWWAN]).andReturn(true);
    for (NSInteger i = 0; i < 30; i++) {
        [self.throttler increaseSentDataBy:40];
    }
    XCTAssertTrue([self.throttler shouldThrottle]);
}

- (void)testShouldNotThrottleWhenWifi
{
    OCMStub([self.reachability isReachableViaWWAN]).andReturn(false);
    [self.throttler increaseSentDataBy:2000];
    XCTAssertFalse([self.throttler shouldThrottle]);
}

- (void)testLimitReached
{
    OCMStub([self.reachability isReachableViaWWAN]).andReturn(true);
    for (NSInteger i = 0; i < 30; i++) {
        [self.throttler increaseSentDataBy:40];
    }
    XCTAssertTrue([self.throttler isLimitReached]);
}

@end
