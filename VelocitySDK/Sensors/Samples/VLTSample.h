//
//  VLTSample.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLTSample <NSObject>

@property (nonatomic, readonly) NSTimeInterval timestamp;
@property (nonatomic, readonly) NSArray<NSNumber *> *values;

@end
