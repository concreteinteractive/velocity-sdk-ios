//
//  VLTManager.h
//  Velocity
//
//  Created by Vytautas Galaunia on 24/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTMotionDetectResult;

@interface VLTManager : NSObject

/**
 @brief Set api token which is used for client authentication
 @param token api token which should be generated by velocity team
 */
+ (void)setApiToken:(nonnull NSString *)token;

/**
 * @brief Enables/Disabled VelocitySDK
 * @param enabled - bool flag which indicates if VelocitySDK should be enabled/disabled
 **/
+ (void)setEnabled:(BOOL)enabled;

/**
 * @brief Return a current state of velocity manager
 * @return BOOL flag, which indicates if SDK is enabled
 **/
+ (BOOL)isEnabled;


/**
 * @brief Enabled or disable tracking
 * @param enabled - bool flag which indicates whether tracking should be enabled
 */
+ (void)setTrackingEnabled:(BOOL)enabled;

/**
 @brief Returns whether Velocity tracking is enabled
 */
+ (BOOL)isTrackingEnabled;

/**
 @brief Sets limit for tracking data
 * @param bytesCount - max bytes sent for tracking during one calendar day using celular
 */
+ (void)setTrackingDataLimit:(NSInteger)bytesCount;

/**
 @brief Returns whether tracking data reached it's threshold
 */
+ (BOOL)isTrackingDataLimitReached;

/**
 * @brief Enabled or disable detection
 * @param enabled - bool flag which indicates whether tracking should be enabled
 * @param handler - handler, which is invoked when detection occurs
 */
+ (void)setDetectionEnabled:(BOOL)enabled handler:(nonnull void(^)(VLTMotionDetectResult * _Nonnull))handler;

/**
 @brief Returns whether Velocity detection is enabled
 */
+ (BOOL)isDetectionEnabled;

/**
 * @brief Mark current motion with given labels
 */
+ (void)labelCurrentMotionWith:(nonnull NSArray<NSString *> *)labels;

/**
 @brief Sets user id, which should uniquely identify user
 @param userId string, which uniquely identifying user
 */
+ (void)setUserId:(nullable NSString *)userId;

/**
 @brief Control the state of core motion activity tracking
 @param enabled New state of core motion activity tracking
 */
+ (void)setMotionActivityTrackingEnabled:(BOOL)enabled;

/**
 @brief Marks given goal and event as completed
 @param goalId - goal id which was completed
 @param eventId - event id which was completed
 @param success - callback for API call completion
 @param failure - callback for API call failure
 */
+ (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure;

@end
