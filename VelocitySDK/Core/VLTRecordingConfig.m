//
//  VLTRecordingConfig.m
//  Velocity
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTRecordingConfig.h"
#import "VLTErrors.h"
#import "Velocity.pbobjc.h"

@interface VLTRecordingConfig ()

@property (nonatomic, assign) NSTimeInterval sampleSize;
@property (nonatomic, assign) NSTimeInterval captureInterval;
@property (nonatomic, getter=isDetectMotionOn) BOOL detectMotionOn;
@property (nonatomic, getter=isPushLabeledDataOn) BOOL pushLabeledDataOn;

@end

@implementation VLTRecordingConfig

- (nonnull instancetype)initWithHandshakeResponse:(VLTPBHandshakeResponse *)handshakeResponse
{
    self = [super init];
    if (self) {
        _sampleSize        = 6; // handshakeResponse.sampleSize;
        _captureInterval   = 6; // handshakeResponse.captureInterval;
        _detectMotionOn    = handshakeResponse.canLabelMotion;
        _pushLabeledDataOn = handshakeResponse.canLabelMotion;
    }
    return self;
}

@end
