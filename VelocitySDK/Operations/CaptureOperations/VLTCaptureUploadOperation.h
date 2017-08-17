//
//  VLTCaptureUploadOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTCaptureOperation.h"

@interface VLTCaptureUploadOperation : VLTCaptureOperation

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSError *);

@end
