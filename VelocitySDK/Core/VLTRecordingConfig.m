//
//  VLTRecordingConfig.m
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTRecordingConfig.h"
#import "VLTErrors.h"

@interface VLTRecordingConfig ()

@property (nonatomic, assign) NSTimeInterval sampleSize;
@property (nonatomic, assign) NSTimeInterval captureInterval;
@property (nonatomic, getter=isDetectMotionOn) BOOL detectMotionOn;
@property (nonatomic, getter=isPushLabeledDataOn) BOOL pushLabeledDataOn;

@end

@implementation VLTRecordingConfig

+ (instancetype)configWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    NSTimeInterval sampleSize = [dictionary[@"sample_size"] doubleValue];
    NSTimeInterval captureInterval = [dictionary[@"capture_interval"] doubleValue];
    BOOL detectMotionOn = [dictionary[@"detect_motion_enabled"] boolValue];
    BOOL pushLabeledDataOn = [dictionary[@"push_labeled_data_enabled"] boolValue];

    if (sampleSize > 0 && captureInterval > 0) {
        VLTRecordingConfig *config = [[VLTRecordingConfig alloc] initSampleSize:sampleSize
                                                                       interval:captureInterval
                                                               detectioMotionOn:detectMotionOn
                                                              pushLabeledDataOn:pushLabeledDataOn];
        return config;
    }

    if (error != NULL) {
        NSDictionary *uInfo;
        uInfo = @{NSLocalizedDescriptionKey : @"Sample and capture interval needs to be greater than 0"};
        *error = [NSError errorWithDomain:VLTErrorDomain
                                     code:VLTParseError
                                 userInfo:uInfo];
    }
    return nil;
}

- (nonnull instancetype)initSampleSize:(NSTimeInterval)sampleSize
                              interval:(NSTimeInterval)captureInterval
                      detectioMotionOn:(BOOL)detectMotionOn
                     pushLabeledDataOn:(BOOL)pushLabeledDataOn
{
    self = [super init];
    if (self) {
        _sampleSize = sampleSize;
        _captureInterval = captureInterval;
        _detectMotionOn = detectMotionOn;
        _pushLabeledDataOn = pushLabeledDataOn;
    }
    return self;
}

@end
