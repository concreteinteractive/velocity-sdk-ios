//
//  VLTDetectOperationTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 18/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTDetectOperation.h"
#import <OCMock/OCMock.h>

@interface VLTDetectOperationTests : XCTestCase

@end

@implementation VLTDetectOperationTests

- (void)testOperationExecution
{
    VLTDetectOperation *op = [[VLTDetectOperation alloc] init];
    VLTDetectOperation *opMock = OCMPartialMock(op);

    OCMExpect([opMock processMotionRequest]).andDo(nil);

    [opMock start];
    [opMock waitUntilFinished];

    OCMVerifyAll((id)opMock);
}

@end
