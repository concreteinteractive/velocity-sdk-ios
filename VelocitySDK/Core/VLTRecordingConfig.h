//
//  VLTRecordingConfig.h
//  Velocity
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTPBHandshakeResponse;

@interface VLTRecordingConfig : NSObject

@property (nonatomic, readonly) NSTimeInterval sampleSize;
@property (nonatomic, readonly) NSTimeInterval captureInterval;
@property (nonatomic, readonly, getter=isDetectMotionOn) BOOL detectMotionOn;
@property (nonatomic, readonly, getter=isPushLabeledDataOn) BOOL pushLabeledDataOn;

- (nonnull instancetype)initWithHandshakeResponse:(nonnull VLTPBHandshakeResponse *)handshakeResponse;

@end
