//
//  VLTSensorBuilder.h
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTMotionRecorder.h"

@interface VLTSensorBuilder : NSObject

+ (nonnull id<VLTMotionRecorder>)buildRecorder;

@end
