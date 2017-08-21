//
//  VLTRecordingConfig.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTRecordingConfig : NSObject

@property (nonatomic, readonly) NSTimeInterval sampleSize;
@property (nonatomic, readonly) NSTimeInterval captureInterval;
@property (nonatomic, readonly, getter=isDetectMotionOn) BOOL detectMotionOn;
@property (nonatomic, readonly, getter=isPushLabeledDataOn) BOOL pushLabeledDataOn;

+ (nullable instancetype)configWithDictionary:(nonnull NSDictionary *)dictionary
                                        error:(NSError * _Nullable * _Nullable)error;

- (nonnull instancetype)initSampleSize:(NSTimeInterval)sampleSize
                              interval:(NSTimeInterval)captureInterval
                      detectioMotionOn:(BOOL)detectMotionOn
                     pushLabeledDataOn:(BOOL)pushLabeledDataOn;

@end
