//
//  VLTWsCaptureUploadOperation.h
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTCaptureUpload.h"
#import "VLTWsApiOperation.h"

@interface VLTWsCaptureUploadOperation : VLTWsApiOperation <VLTCaptureUpload>

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void (^onError)(NSUInteger bytesSent, NSError *error);
@property (atomic, copy) void (^onSuccess)(NSUInteger bytesSent);

@end
