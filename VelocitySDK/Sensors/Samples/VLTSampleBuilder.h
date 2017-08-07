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

+ (id<VLTSample>)sampleFrom:(id)sourceData;

@end
