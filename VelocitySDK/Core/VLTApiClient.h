//
//  VLTApiClient.h
//  Velocity
//
//  Created by Antanas Majus on 10/20/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
@class VLTPBCapture;
@class VLTRecordingConfig;
@class VLTPBDetectMotionRequest;
@class VLTDetectResult;

@interface VLTApiClient : NSObject

+ (nonnull VLTApiClient *)shared;

- (void)setApiToken:(nonnull NSString *)token;

- (void)getConfigWithIFA:(nullable NSString *)ifa
                 success:(nullable void (^)(VLTRecordingConfig * _Nonnull config))success
                 failure:(nullable void (^)(NSError *_Nonnull error))failure;

- (void)uploadForTracking:(nonnull VLTPBCapture *)capture
                  success:(nullable void (^)(void))success
                  failure:(nullable void (^)(NSError *_Nonnull error))failure;

- (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure;

- (void)detect:(nonnull VLTPBDetectMotionRequest *)detectMotionRequest
       success:(nullable void (^)(VLTDetectResult * _Nonnull result))success
       failure:(nullable void (^)(NSError * _Nonnull error))failure;

@end
