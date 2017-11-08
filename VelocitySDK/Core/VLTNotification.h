//
//  VLTNotification.h
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTConstants.h"

@interface VLTNotification : NSObject

@property (nonatomic, readonly) BOOL isSilent;
@property (nonnull, nonatomic, readonly) NSString *activityName;
@property (nonnull, nonatomic, readonly) NSString *notificationId;
@property (nonnull, nonatomic, readonly) NSString *message;

+ (nullable VLTNotification *)fromUserInfo:(nonnull NSDictionary *)userInfo;

@end
