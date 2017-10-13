//
//  VLTCaptureUploadOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDataOperation.h"

@interface VLTCaptureUploadOperation : VLTMotionDataOperation

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSUInteger bytesSent, NSError *);
@property (atomic, copy) void(^onSuccess)(NSUInteger bytesSent);

@end
