//
//  VLTSensorRecorder.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSensorTypes.h"
#import "VLTSample.h"
#import "VLTMotionRecorder.h"

@class VLTData;

@interface VLTSensorRecorder : NSObject <VLTMotionRecorder>

@property (nonatomic, readonly) VLTSensorType sensorType;
@property (nonatomic, readonly) NSTimeInterval updateInterval;
@property (nonatomic, readonly) NSTimeInterval keepTimeInBuffer;

- (nonnull instancetype)initWithUpdateInterval:(NSTimeInterval)interval timeInBuffer:(NSTimeInterval)timeInBuffer;

- (nonnull instancetype)initWithUpdateInterval:(NSTimeInterval)interval
                                  timeInBuffer:(NSTimeInterval)timeInBuffer
                                    sensorType:(VLTSensorType)type NS_DESIGNATED_INITIALIZER;

- (void)addSample:(nonnull id<VLTSample>)sample;

@end
