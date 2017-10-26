//
//  VLTRecordingConfig.m
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
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
        _sampleSize = handshakeResponse.sampleSize;
        _captureInterval = handshakeResponse.captureInterval;
        _detectMotionOn = handshakeResponse.canLabelMotion;
        _pushLabeledDataOn = handshakeResponse.canLabelMotion;
    }
    return self;
}

@end
