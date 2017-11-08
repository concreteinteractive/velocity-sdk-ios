//
//  VLTUserData.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTRecordingConfig;

@interface VLTUserDataStore : NSObject

@property (atomic, strong, nullable) NSString *userId;
@property (atomic, assign, getter=isGpsEnabled) BOOL gpsEnabled;
@property (atomic, strong, readonly, nullable) VLTRecordingConfig *recordingConfig;
@property (atomic, strong, readonly, nonnull) NSString *sessionId;

+ (nonnull instancetype)shared;

@end
