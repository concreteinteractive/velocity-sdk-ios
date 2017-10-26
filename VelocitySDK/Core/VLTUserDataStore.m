//
//  VLTUserData.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLTUserDataStore.h"
#import "VLTApiClient.h"
#import "VLTMacros.h"
#import "VLTRecordingConfig.h"
#import "VLTConfig.h"

@interface VLTUserDataStore ()

@property (atomic,  strong, nullable) VLTRecordingConfig *recordingConfig;
@property (atomic,  strong, nonnull) NSString *sessionId;

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
        _userId = [VLTConfig defaultUserID];
        _sessionId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

@end
