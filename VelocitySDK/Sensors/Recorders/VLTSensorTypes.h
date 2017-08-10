//
//  VLTSensorTypes.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#ifndef VLTSensorTypes_h
#define VLTSensorTypes_h

typedef NS_ENUM(NSInteger, VLTSensorType) {
    VLTSensorTypeNotSpecified   = -1,
    VLTSensorTypeAcc            = 0,
    VLTSensorTypeGyro           = 1,
    VLTSensorTypeMag            = 2,
    VLTSensorTypeGPS            = 3,
};

#endif /* VLTSensorTypes_h */
