//
//  VLTSensorRecorder.m
//  Tests
//
//  Created by Antanas Majus on 12/22/17.
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VLTSensorRecorder.h"
#import "VLTSimpleSample.h"
#import "VLTData.h"

@interface VLTSensorRecorderTests: XCTestCase

@property (nonatomic, strong) VLTSensorRecorder *recorder;

@end

@implementation VLTSensorRecorderTests

- (void)setUp {
    [super setUp];
    self.recorder = [[VLTSensorRecorder alloc] initWithUpdateInterval:0.1 timeInBuffer:50 sensorType:VLTSensorTypeAcc];
}

- (void)testDataForTimeIntervalWhenIntervalIsBigger {
    NSTimeInterval nowTimestamp = [NSDate date].timeIntervalSince1970;
    for (NSInteger i = 0; i < 600; i++) {
        VLTSimpleSample *sample = [[VLTSimpleSample alloc] initWithTimestamp:nowTimestamp + i/100.0 values:@[]];
        [self.recorder addSample:sample];
    }
    NSArray <VLTData*> *datas = [self.recorder dataForTimeInterval:20];
    XCTAssertEqual(datas.count, 1);
    XCTAssertEqual(datas[0].values.count, 600);
}

- (void)testDataForTimeIntervalWhenIntervalIsSmaller {
    NSTimeInterval nowTimestamp = [NSDate date].timeIntervalSince1970;
    for (NSInteger i = 0; i < 600; i++) {
        VLTSimpleSample *sample = [[VLTSimpleSample alloc] initWithTimestamp:nowTimestamp + i/100.0 values:@[]];
        [self.recorder addSample:sample];
    }
    NSArray <VLTData*> *datas = [self.recorder dataForTimeInterval:2];
    XCTAssertEqual(datas.count, 1);
    NSInteger samplesCount = datas[0].values.count;
    XCTAssertTrue(samplesCount > 198);
    XCTAssertTrue(samplesCount < 202);
}

- (void)testDataForTimeIntervalWhenNoDataGathered {
    NSArray <VLTData*> *datas = [self.recorder dataForTimeInterval:2];
    XCTAssertEqual(datas.count, 1);
    XCTAssertEqual(datas[0].values.count, 0);
}

@end
