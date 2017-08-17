//
//  VLTCaptureOperationTests.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 18/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTCaptureOperation.h"
#import <OCMock/OCMock.h>

@interface VLTCaptureOperationTests : XCTestCase

@end

@implementation VLTCaptureOperationTests

- (void)testOperationExecution
{
    VLTCaptureOperation *captureOperation = [[VLTCaptureOperation alloc] init];

    VLTCaptureOperation *captureOperationMock = OCMPartialMock(captureOperation);

    OCMExpect([captureOperationMock processCaptureRequest]).andDo(nil);

    [captureOperationMock start];
    [captureOperationMock waitUntilFinished];

    OCMVerifyAll((id)captureOperationMock);
}

@end
