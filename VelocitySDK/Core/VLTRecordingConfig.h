//
//  VLTRecordingConfig.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
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
