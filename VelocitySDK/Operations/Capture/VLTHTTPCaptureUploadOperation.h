//
//  VLTHTTPCaptureUploadOperation.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTCaptureUpload.h"
#import "VLTMotionDataOperation.h"

@interface VLTHTTPCaptureUploadOperation : VLTMotionDataOperation <VLTCaptureUpload>

@property (atomic, strong, readonly, nullable) NSError *error;
@property (atomic, copy, nullable) void (^onError)(NSUInteger bytesSent, NSError *_Nonnull);
@property (atomic, copy, nullable) void (^onSuccess)(NSUInteger bytesSent);

@end
