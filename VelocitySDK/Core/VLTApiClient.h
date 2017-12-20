//
//  VLTApiClient.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTPBCapture;
@class VLTRecordingConfig;
@class VLTPBDetectMotionRequest;
@class VLTMotionDetectResult;

@interface VLTApiClient : NSObject

+ (nonnull VLTApiClient *)shared;

- (void)setApiToken:(nonnull NSString *)token;

- (void)uploadForTracking:(nonnull VLTPBCapture *)capture
                  success:(nullable void (^)(NSUInteger bytesSent))success
                  failure:(nullable void (^)(NSUInteger bytesSent, NSError *_Nonnull error))failure;

- (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure;

- (void)detect:(nonnull VLTPBDetectMotionRequest *)detectMotionRequest
       success:(nullable void (^)(VLTMotionDetectResult *_Nonnull result))success
       failure:(nullable void (^)(NSError *_Nonnull error))failure;

- (void)uploadMotionData:(nullable VLTPBCapture *)capture
                  labels:(nonnull NSArray<NSString *> *)labels
                 success:(nullable void (^)(void))success
                 failure:(nullable void (^)(NSError *_Nonnull error))failure;

@end
