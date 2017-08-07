//
//  VLTData.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
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
