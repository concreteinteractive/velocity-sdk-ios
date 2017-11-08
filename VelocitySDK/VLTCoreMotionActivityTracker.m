//
//  VLTCoreMotionActivityTracker.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTCoreMotionActivityTracker.h"
#import "VLTCore.h"
#import "VLTMacros.h"

@interface VLTCoreMotionActivityTracker ()

@property (nonatomic, strong) CMMotionActivityManager *motionActivityManager;
@property (atomic, strong) CMMotionActivity *recentActivity;

@end

@implementation VLTCoreMotionActivityTracker

@synthesize enabled = _enabled;

+ (instancetype)shared
{
    static VLTCoreMotionActivityTracker *shared = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        shared = [[VLTCoreMotionActivityTracker alloc] init];
    });
    return shared;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _motionActivityManager = [[CMMotionActivityManager alloc] init];
    }
    return self;
}

- (void)setEnabled:(BOOL)enabled
{
    @synchronized(self) { _enabled = enabled; }
    [self updateAfterStateChange];
}

- (BOOL)isEnabled
{
    @synchronized(self) { return _enabled; }
}

- (void)updateAfterStateChange
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.enabled) {
            vlt_weakify(self);
            [self.motionActivityManager startActivityUpdatesToQueue:[VLTCore queue]
                                                        withHandler:^(CMMotionActivity *_Nullable activity) {
                                                            vlt_strongify(self);
                                                            self.recentActivity = activity;
                                                        }];
        } else {
            [self.motionActivityManager stopActivityUpdates];
        }
    });
}

@end
