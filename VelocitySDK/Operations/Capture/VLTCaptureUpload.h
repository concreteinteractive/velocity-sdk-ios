//
//  VLTCaptureUpload.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 25/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLTCaptureUpload <NSObject>

@property (atomic, strong, readonly) NSError *error;
@property (atomic, copy) void(^onError)(NSUInteger bytesSent, NSError *);
@property (atomic, copy) void(^onSuccess)(NSUInteger bytesSent);

@end
