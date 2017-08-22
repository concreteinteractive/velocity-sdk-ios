//
//  VLTSampleBuilder.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

extern const NSInteger VLTSampleLatitudeIndex;
extern const NSInteger VLTSampleLongitudeIndex;
extern const NSInteger VLTSampleAltitudeIndex;
extern const NSInteger VLTSampleHorizontalAccuracyIndex;
extern const NSInteger VLTSampleSpeedIndex;

extern const NSInteger VLTLocationSampleValuesCount;

@interface VLTSampleBuilder : NSObject

+ (nonnull id<VLTSample>)sampleFrom:(nonnull id)sourceData;

+ (nonnull id<VLTSample>)simulatorSample;

@end
