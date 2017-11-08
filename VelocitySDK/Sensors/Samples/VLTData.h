//
//  VLTData.h
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSensorRecorder.h"
#import "VLTSample.h"

@interface VLTData : NSObject

@property (nonatomic, readonly) VLTSensorType sensorType;
@property (nonatomic, readonly, nonnull) NSArray <id<VLTSample>> *values;

- (nonnull instancetype)initWithSensorType:(VLTSensorType)sensorType
                                    values:(nonnull NSArray<id<VLTSample>> *)values;


@end
