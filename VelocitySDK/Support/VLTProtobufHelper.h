//
//  ProtobufHelper.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

@class VLTPBCapture;
@class VLTPBSensor;
@class VLTPBSample;
@class VLTData;
@class VLTPBDetectMotionRequest;
@class VLTPBHandshakeRequest;

@interface VLTProtobufHelper : NSObject

+ (nonnull VLTPBCapture *)captureFromDatas:(nonnull NSArray<VLTData *> *)datas
                                       ifa:(nullable NSString *)ifa
                             sequenceIndex:(UInt32)seqIndex
                              impressionId:(nonnull NSString *)impressionId;

+ (nonnull VLTPBDetectMotionRequest *)detectMotionRequestFromDatas:(nonnull NSArray<VLTData *> *)datas
                                                      impressionId:(nonnull NSString *)impressionId
                                                        modelNames:(nonnull NSArray<NSString *> *)modelNames
                                                               ifa:(nullable NSString *)ifa
                                                            userId:(nullable NSString *)userId
                                                     sequenceIndex:(UInt32)seqIndex;

+ (nonnull VLTPBSensor *)sensorFromData:(nonnull VLTData *)data;

+ (nonnull VLTPBSample *)sampleToVLTPBSample:(nonnull id<VLTSample>)sample;

+ (nonnull VLTPBHandshakeRequest *)handshakeRequestWithAuthToken:(nonnull NSString *)authToken
                                                            idfa:(nonnull NSString *)idfa
                                                          userId:(nonnull NSString *)userId;

+ (nonnull NSArray<VLTPBSample *> *)sensorsFromMotionData:(nonnull NSArray<VLTData *> *)datas;

@end
