//
//  VLTUserData.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTUserDataStore.h"
#import <UIKit/UIKit.h>
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMacros.h"
#import "VLTRecordingConfig.h"

@interface VLTUserDataStore ()

@property (atomic, strong, nullable) VLTRecordingConfig *recordingConfig;
@property (atomic, strong, nonnull) NSString *sessionId;

@end

@implementation VLTUserDataStore

+ (nonnull instancetype)shared
{
    static VLTUserDataStore *sharedUserDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserDataStore = [[VLTUserDataStore alloc] init];
    });
    return sharedUserDataStore;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _userId    = [VLTConfig defaultUserID];
        _sessionId = [[NSUUID UUID] UUIDString];
        _IFAEnabled = YES;
    }
    return self;
}

- (NSString *)IFA
{
    if (self.isIFAEnabled && [VLTConfig trackingEnabled]) {
        return [VLTConfig IFA];
    }
    return @"";
}

@end
