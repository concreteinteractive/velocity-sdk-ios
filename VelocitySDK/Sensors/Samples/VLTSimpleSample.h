//
//  VLTSample.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTSample.h"

@interface VLTSimpleSample : NSObject <VLTSample>

- (nonnull instancetype)initWithTimestamp:(NSTimeInterval)timestamp x:(float)x y:(float)y z:(float)z;
- (nonnull instancetype)initWithTimestamp:(NSTimeInterval)timestamp
                                   values:(nonnull NSArray<NSNumber *> *)values NS_DESIGNATED_INITIALIZER;

@end
