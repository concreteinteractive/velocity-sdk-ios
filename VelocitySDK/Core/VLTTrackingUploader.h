//
//  VLTTrackingPredictionUploader.h
//  Velocity
//
//  Created by Vytautas Galaunia on 19/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTMotionRecorder.h"

@interface VLTTrackingUploader : NSObject

@property (nonatomic, readonly, nonnull) id <VLTMotionRecorder> recorder;
@property (nonatomic, readonly, nonnull) NSString *impressionId;
@property (nonatomic, readonly) NSTimeInterval sampleSize;
@property (atomic, readonly) BOOL isUploading;

@property (nonatomic, copy, nullable) void(^onError)(NSError * _Nonnull  error);
@property (nonatomic, copy, nullable) void(^onUpload)();

- (nonnull instancetype)initWithRecorder:(nonnull id<VLTMotionRecorder>)recorder
                            impressionId:(nonnull NSString *)impressionId
                              sampleSize:(NSTimeInterval)sampleSize;

- (void)startUploading;
- (void)stopUploading;

@end
