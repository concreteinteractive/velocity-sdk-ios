//
//  ProtobufHelper.h
//  Velocity
//
//  Created by Antanas Majus on 10/25/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

@class VLTPBCapture;
@class VLTPBSensor;
@class VLTPBSample;
@class VLTData;

@interface VLTProtobufHelper : NSObject


+ (nonnull VLTPBCapture *)captureFromDatas:(nonnull NSArray <VLTData *> *)datas
                                       ifa:(nonnull NSString *)ifa
                             sequenceIndex:(UInt32)seqIndex
                              impressionId:(nonnull NSString *)impressionId;

+ (nonnull VLTPBSensor *)sensorFromData:(nonnull VLTData *)data;

+ (nonnull VLTPBSample *)sampleToVLTPBSample:(nonnull id <VLTSample> )sample;

@end
