//
//  VLTMotionRecoring.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTData;

@protocol VLTMotionRecorder <NSObject>

- (void)startRecording;
- (void)stopRecording;
- (NSTimeInterval)availableTimeInBuffer;

- (nonnull NSArray<VLTData *> *)dataForTimeInterval:(NSTimeInterval)interval;

@end
