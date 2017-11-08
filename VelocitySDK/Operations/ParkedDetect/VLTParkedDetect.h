//
//  VLTParkedDetect.h
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VLTParkedDetect <NSObject>

@property (atomic, strong, readonly, nullable) VLTMotionDetectResult *result;
@property (atomic, strong, readonly, nullable) NSError *error;

@property (atomic, copy, nullable) void (^onMotionDetect)(VLTMotionDetectResult *_Nonnull);
@property (atomic, copy, nullable) void (^onError)(NSError *_Nonnull);

@end
