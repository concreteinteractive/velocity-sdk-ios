//
//  VLTNotification.m
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTNotification.h"

@interface VLTNotification ()

@property (nonatomic) BOOL isSilent;
@property (nonnull, nonatomic) NSString *activityName;
@property (nonnull, nonatomic) NSString *notificationId;
@property (nonnull, nonatomic) NSString *message;

@end

@implementation VLTNotification

+ (VLTNotification *)fromUserInfo:(NSDictionary *)userInfo;
{
    return [[VLTNotification alloc] initWithUserInfo:userInfo];
}

- (nullable instancetype)initWithUserInfo:(nonnull NSDictionary *)userInfo
{
    if (!userInfo[VLTDataKey]) {
        return nil;
    }

    NSDictionary *data = userInfo[VLTDataKey];
    if (!data[VLTNotificationIdKey] || !data[VLTActivityNameKey] || !data[VLTMessageKey]) {
        return nil;
    }

    self = [super init];
    if (self) {
        _isSilent       = [userInfo[VLTApsKey][VLTContentAvailableKey] boolValue] ?: false;
        _activityName   = data[VLTActivityNameKey];
        _notificationId = [NSString stringWithFormat:@"%@", data[VLTNotificationIdKey]];
        _message        = data[VLTMessageKey];
    }
    return self;
}

@end
