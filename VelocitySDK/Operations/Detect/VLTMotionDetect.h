//
//  VLTMotionDetect.h
//  VelocitySDK iOS
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTMotionDetectResult;

@protocol VLTMotionDetect <NSObject>

@property (atomic, strong, readonly) VLTMotionDetectResult *result;
@property (atomic, strong, readonly) NSError *error;

@property (atomic, copy) void(^onMotionDetect)(VLTMotionDetectResult *);
@property (atomic, copy) void(^onError)(NSError *);

@end
