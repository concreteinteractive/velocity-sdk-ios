//
//  VLTApiClientTests.m
//  Velocity
//
//  Created by Vytautas Galaunia on 23/02/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <AFNetworking/AFNetworking.h>
#import <OCMock/OCMock.h>
#import <Quick/Quick.h>
#import "VLTApiClient.h"

@interface VLTApiClient ()

- (AFHTTPSessionManager *)jsonManager;

@end

@interface VLTApiClientTests : XCTestCase

@property (nonatomic) id apiClientClassMock;
@property (nonatomic) id apiClientMock;
@property (nonatomic) id jsonManagerMock;

@end

@implementation VLTApiClientTests

- (void)setUp {
    [super setUp];

    self.apiClientMock = OCMPartialMock([VLTApiClient shared]);
    self.apiClientClassMock = OCMClassMock([VLTApiClient class]);
    OCMStub([self.apiClientClassMock shared]).andReturn(self.apiClientMock);

    self.jsonManagerMock = OCMPartialMock([[VLTApiClient shared] jsonManager]);
    OCMStub([self.apiClientMock jsonManager]).andReturn(self.jsonManagerMock);
}

- (void)tearDown {
    [self.apiClientMock stopMocking];
    [self.apiClientClassMock stopMocking];
    [self.jsonManagerMock stopMocking];
    [super tearDown];
}

- (void)testMarkAsCompleted {
    __block NSURLRequest *req;

    OCMStub([self.jsonManagerMock dataTaskWithRequest:[OCMArg checkWithBlock:^BOOL(id obj) {
        req = (NSURLRequest *)obj;
        return YES;
    }]
                                       uploadProgress:[OCMArg any]
                                     downloadProgress:[OCMArg any]
                                    completionHandler:[OCMArg any]]).andDo(nil);

    [[VLTApiClient shared] markGoalAsCompleted:@"GOAL_ID"
                                       eventId:@"EVENT_ID"
                                       success:^{
                                           NSLog(@"Success!");
                                       }
                                       failure:^(NSError * _Nonnull error) {
                                           NSLog(@"Failure!");
                                       }];

    OCMVerifyAll(self.jsonManagerMock);

    XCTAssertNotNil(req, @"Request is nil");
    XCTAssertEqualObjects([req.URL relativePath], @"/api/events");
    XCTAssertEqualObjects([req HTTPMethod], @"POST");

    NSData *blob = [req HTTPBody];
    NSError *jsonError = nil;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:blob options:kNilOptions error:&jsonError];
    XCTAssertNil(jsonError, @"Error should not occur");
    XCTAssertEqualObjects(json[@"event_id"], @"EVENT_ID");
    XCTAssertEqualObjects(json[@"goal_id"], @"GOAL_ID");
}

@end
