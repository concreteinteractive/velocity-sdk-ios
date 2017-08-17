//
//  VLTClient.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTMotionDetectResult;

@interface VLTClient : NSObject

@property (atomic, assign, getter=isDetectionOn) BOOL detectionOn;
@property (atomic, assign, getter=isTrackingOn) BOOL trackingOn;

@property (atomic, assign, getter=isActive) BOOL active;


@property (atomic, copy, nullable) void(^detectHandler)(VLTMotionDetectResult * _Nonnull);

/**  
 * @property errorHandler
 * @brief Block is invoked when error occurs
 * In case of error occurance, active right away is set to false
 **/
@property (atomic, copy, nullable) void(^errorHandler)(NSError * _Nullable);

@end
