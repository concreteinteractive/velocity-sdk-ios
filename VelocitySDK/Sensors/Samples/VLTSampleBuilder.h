//
//  VLTSampleBuilder.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

extern const NSInteger VLTPBSampleLatitudeIndex;
extern const NSInteger VLTPBSampleLongitudeIndex;
extern const NSInteger VLTPBSampleAltitudeIndex;
extern const NSInteger VLTPBSampleHorizontalAccuracyIndex;
extern const NSInteger VLTPBSampleSpeedIndex;

@interface VLTSampleBuilder : NSObject

+ (nonnull id<VLTSample>)sampleFrom:(nonnull id)sourceData;

+ (nonnull id<VLTSample>)simulatorSample;

@end
