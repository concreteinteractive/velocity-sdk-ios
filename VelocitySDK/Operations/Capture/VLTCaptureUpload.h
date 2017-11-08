//
//  VLTCaptureUpload.h
//  VelocitySDK iOS
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLTCaptureUpload <NSObject>

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSUInteger bytesSent, NSError *);
@property (atomic, copy) void(^onSuccess)(NSUInteger bytesSent);

@end
