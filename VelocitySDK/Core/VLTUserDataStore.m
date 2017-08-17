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
@property (atomic,  strong) NSString *impressionId;

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
        _impressionId = [[NSUUID UUID] UUIDString];
    }
    return self;
}

- (void)updateConfigWithSuccess:(nullable void (^)(VLTRecordingConfig * _Nonnull config))success
                        failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    vlt_weakify(self);
    [[VLTApiClient shared] configWithIFA:[VLTConfig IFA]
                                 success:^(VLTRecordingConfig *config) {
                                     vlt_strongify(self);
                                     self.recordingConfig = config;
                                     vlt_invoke_block(success, config);
                                 } failure:^(NSError *error) {
                                     vlt_invoke_block(failure, error);
                                 }];
}

@end
