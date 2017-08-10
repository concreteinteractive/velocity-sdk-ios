//
//  ProtobufHelper.m
//  Velocity
//
//  Created by Antanas Majus on 10/25/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTProtobufHelper.h"
#import "Velocity.pb.h"
#import "VLTErrors.h"
#import "VLTData.h"
#import "VLTMacros.h"

@implementation VLTProtobufHelper

+ (nonnull VLTPBCapture *)captureFromDatas:(nonnull NSArray <VLTData *> *)datas
                                       ifa:(nullable NSString *)ifa
                             sequenceIndex:(UInt32)seqIndex
                              impressionId:(nonnull NSString *)impressionId;
{
    NSMutableArray <VLTPBSensor *> *sensors = [NSMutableArray array];

    for (VLTData *data in datas) {
        [sensors addObject:[VLTProtobufHelper sensorFromData:data]];
    }

    VLTPBCaptureBuilder *builder = [[VLTPBCaptureBuilder alloc] init];
    [builder setSensorsArray:sensors];
    [builder setIfa:ifa];
    [builder setTimestamp:[NSDate date].timeIntervalSince1970];
    [builder setPlatform:VLTPBPlatformTypeIos];
    [builder setSequenceIndex:seqIndex];
    [builder setImpressionId:impressionId];
    [builder setAppId:[[NSBundle mainBundle] bundleIdentifier]];

    VLTPBCapture *capture = [builder build];
    return capture;
}

+ (nonnull VLTPBDetectMotionRequest *)detectMotionRequestFromDatas:(nonnull NSArray <VLTData *> *)datas
                                                      impressionId:(nonnull NSString *)impressionId
                                                        modelNames:(nonnull NSArray<NSString *> *)modelNames
                                                               ifa:(nullable NSString *)ifa
                                                            userId:(nullable NSString *)userId
                                                     sequenceIndex:(UInt32)seqIndex
{
    NSMutableArray <VLTPBSensor *> *sensors = [NSMutableArray array];
    for (VLTData *data in datas) {
        [sensors addObject:[VLTProtobufHelper sensorFromData:data]];
    }

    VLTPBDetectMotionRequestBuilder *builder = [[VLTPBDetectMotionRequestBuilder alloc] init];
    [builder setId:impressionId];
    [builder setUserId:userId];
    [builder setModelNameArray:modelNames];
    [builder setSensorsArray:sensors];
    [builder setSequenceIndex:seqIndex];
    [builder setPlatform:VLTPBPlatformTypeIos];
    [builder setTimestamp:[NSDate date].timeIntervalSince1970];

    VLTPBDetectMotionRequest *motionRequest = [builder build];
    return motionRequest;
}

+ (nonnull VLTPBSensor *)sensorFromData:(nonnull VLTData *)data
{
    VLTPBSensorBuilder *builder = [[VLTPBSensorBuilder alloc] init];
    switch (data.sensorType) {
        case VLTSensorTypeAcc:
            [builder setType:VLTPBSensorTypeAccel];
            break;
        case VLTSensorTypeGyro:
            [builder setType:VLTPBSensorTypeGyro];
            break;
        case VLTSensorTypeGPS:
            [builder setType:VLTPBSensorTypeGps];
            break;
        default:
            DLog(@"sensorFromData: builder type is not supported");
            break;
    }

    for (id <VLTSample> sample in data.values) {
        [builder addSamples:[VLTProtobufHelper sampleToVLTPBSample:sample]];
    }
    return [builder build];
}

+ (nonnull VLTPBSample *)sampleToVLTPBSample:(nonnull id <VLTSample> )sample
{
    VLTPBSampleBuilder *builder = [[VLTPBSampleBuilder alloc] init];
    [builder setTimestamp:sample.timestamp];
    [builder setValuesArray:sample.values];
    return [builder build];
}

@end
