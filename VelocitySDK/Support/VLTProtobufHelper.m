//
//  ProtobufHelper.m
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTProtobufHelper.h"
#import "Velocity.pbobjc.h"
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

    VLTPBCapture *capture = [[VLTPBCapture alloc] init];
    capture.sensorsArray = sensors;
    capture.ifa = ifa;
    capture.timestamp = [NSDate date].timeIntervalSince1970;
    capture.platform = VLTPBPlatformType_Ios;
    capture.sequenceIndex = seqIndex;
    capture.impressionId = impressionId;
    capture.appId = [[NSBundle mainBundle] bundleIdentifier];
    
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

    VLTPBDetectMotionRequest *motionRequest = [[VLTPBDetectMotionRequest alloc] init];
    motionRequest.id_p = impressionId;
    motionRequest.userId = userId;
    motionRequest.modelNameArray = [modelNames mutableCopy];
    motionRequest.sensorsArray = sensors;
    motionRequest.sequenceIndex = seqIndex;
    motionRequest.platform = VLTPBPlatformType_Ios;
    motionRequest.timestamp = [NSDate date].timeIntervalSince1970;
    return motionRequest;
}

+ (nonnull VLTPBSensor *)sensorFromData:(nonnull VLTData *)data
{

    VLTPBSensor *sensor = [[VLTPBSensor alloc] init];
    switch (data.sensorType) {
        case VLTSensorTypeAcc:
            sensor.type = VLTPBSensor_Type_Accel;
            break;
        case VLTSensorTypeGyro:
            sensor.type = VLTPBSensor_Type_Gyro;
            break;
        case VLTSensorTypeGPS:
            sensor.type = VLTPBSensor_Type_Gps;
            break;
        default:
            DLog(@"sensorFromData: builder type is not supported");
            break;
    }

    NSMutableArray<VLTPBSample*> *samples = [[NSMutableArray alloc] init];
    for (id <VLTSample> sample in data.values) {
        [samples addObject:[VLTProtobufHelper sampleToVLTPBSample:sample]];
    }
    sensor.samplesArray = samples;
    return sensor;
}

+ (nonnull VLTPBSample *)sampleToVLTPBSample:(nonnull id <VLTSample> )sample
{
    GPBFloatArray *floatsArray = [[GPBFloatArray alloc] init];
    [sample.values enumerateObjectsUsingBlock:^(NSNumber * _Nonnull number, NSUInteger idx, BOOL * _Nonnull stop) {
        [floatsArray addValue:[number floatValue]];
    }];

    VLTPBSample *pbSample = [[VLTPBSample alloc] init];
    pbSample.timestamp = sample.timestamp;
    pbSample.valuesArray = floatsArray;
    return pbSample;
}

+ (nonnull NSArray<VLTPBSample *> *)sensorsFromMotionData:(nonnull NSArray <VLTData *> *)datas;
{
    NSMutableArray <VLTPBSensor *> *sensors = [NSMutableArray array];
    for (VLTData *data in datas) {
        [sensors addObject:[VLTProtobufHelper sensorFromData:data]];
    }
    return [sensors copy];
}


+ (nonnull VLTPBHandshakeRequest *)handshakeRequestWithAuthToken:(nonnull NSString *)authToken
                                                            idfa:(nonnull NSString *)idfa
                                                          userId:(nonnull NSString *)userId
{
    VLTPBHandshakeRequest *request = [[VLTPBHandshakeRequest alloc] init];
    request.authToken = authToken;
    request.idfa = idfa;
    request.userId = userId;
    request.appId = [[NSBundle mainBundle] bundleIdentifier];
    request.platform = VLTPBPlatformType_Ios;
    return request;
}

@end
