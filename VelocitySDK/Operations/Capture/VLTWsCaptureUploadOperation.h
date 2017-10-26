//
//  VLTWsCaptureUploadOperation.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTWsApiOperation.h"
#import "VLTCaptureUpload.h"

@interface VLTWsCaptureUploadOperation : VLTWsApiOperation <VLTCaptureUpload>

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSUInteger bytesSent, NSError *error);
@property (atomic, copy) void(^onSuccess)(NSUInteger bytesSent);

@end
