//
//  VLTSampleBuilder.h
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

@interface VLTSampleBuilder : NSObject

+ (nonnull id<VLTSample>)sampleFrom:(nonnull id)sourceData;

+ (nonnull id<VLTSample>)simulatorSample;

@end
