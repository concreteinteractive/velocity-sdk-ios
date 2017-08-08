//
//  VLTPredictor.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLTDetector.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMotionRecorder.h"
#import "VLTDetectUploader.h"
#import "VLTSensorBuilder.h"
#import "VLTRecordingConfig.h"
#import "VLTErrors.h"
#import "VLTMacros.h"
#import "VLTDetectResult.h"
#import "VLTCore.h"

static const NSTimeInterval VLTDetectorCheckInterval = 120;

@interface VLTDetector ()

@property (atomic, strong) id <VLTMotionRecorder> recorder;
@property (atomic, assign, getter=isActive) BOOL active;
@property (atomic, strong) VLTDetectUploader *uploader;
@property (atomic, strong) dispatch_source_t checkTimer;
@property (atomic, copy) void(^onDetectReceived)(VLTDetectResult *);
@property (atomic, strong) NSDate *lastUploadDate;

@property (atomic, assign) NSTimeInterval sampleSize;
@property (atomic, assign) NSTimeInterval captureInterval;

@end

@implementation VLTDetector

+ (void)activate
{
    [[VLTDetector shared] updateConfigAndStart:YES];
}

+ (void)deactivate
{
    [[VLTDetector shared] stop];
}

+ (BOOL)isActive
{
    return [VLTDetector shared].isActive;
}

+ (void)setOnDetectReceivedHandler:(void(^)(VLTDetectResult *))handler
{
    [VLTDetector shared].onDetectReceived = handler;
}

+ (instancetype)shared
{
    static VLTDetector *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VLTDetector alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _recorder = [VLTSensorBuilder buildRecorder];
        [self reinitUploader];
    }
    return self;
}

- (void)reinitUploader
{
    if (self.uploader) {
        [self.uploader stopUploading];
        self.uploader = nil;
    }
    self.uploader = [[VLTDetectUploader alloc] initWithRecorder:self.recorder
                                                   impressionId:[[NSUUID UUID] UUIDString]
                                                     sampleSize:self.sampleSize];
    vlt_weakify(self);
    self.uploader.onError = ^(NSError *error) {
        DLog(@"Uploader error: %@", error);
        [weak_self handleError:error];
    };

    self.uploader.onSuccess = ^(VLTDetectResult *result) {
        weak_self.lastUploadDate = [NSDate date];
        dispatch_async(dispatch_get_main_queue(), ^{
            vlt_invoke_block(weak_self.onDetectReceived, result);
        });
    };
}

- (void)handleError:(NSError *)error
{
    if (error && [error.domain isEqualToString:VLTErrorDomain]) {
        switch (error.code) {
            case VLTApiFatalError:
            case VLTApiTokenNotRecognized:
            case VLTApiTokenNoAccess:
                [self easyStop];
                break;
            default:
                break;
        }
    }
}

- (void)dealloc
{
    [self unsubscribe];
}

- (void)subscribe
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(didEnterBackground)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(willEnterForeground)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];
}

- (void)unsubscribe
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [nc removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)didEnterBackground
{
    [self invalidateTimer];
}

- (void)willEnterForeground
{
    if (!self.isActive) {
        return;
    }

    [self updateConfigAndStart:NO];
    [self startCheckTimer];
}

- (void)updateConfigAndStart:(BOOL)freshStart
{
    vlt_weakify(self);
    [[VLTApiClient shared] getConfigWithIFA:[VLTConfig IFA]
                                    success:^(VLTRecordingConfig *config) {
                                        vlt_strongify(self);

                                        if (![config isValid]) {
                                            DLog(@"Velocity SDK Config is Invalid");
                                            return;
                                        }
                                        if (!config.isDetectMotionOn) {
                                            DLog(@"Velocity SDK Config - motion detection is off.");
                                            return;
                                        }

                                        self.sampleSize = config.sampleSize;
                                        self.captureInterval = config.captureInterval;
                                        if (freshStart) {
                                            [self start];
                                        } else {
                                            [self startIfPossible];
                                        }
                                    } failure:^(NSError *error) {
                                        DLog(@"Velocity SDK Config get error: %@", error);
                                    }];
}

- (void)start
{
    if (self.isActive) {
        return;
    }
    self.active = YES;
    [self subscribe];
    [self startCheckTimer];
    [self startIfPossible];
}

- (void)stop
{
    if (!self.isActive) {
        return;
    }

    self.active = NO;
    [self unsubscribe];
    [self invalidateTimer];
    [self easyStop];
}

- (void)easyStop
{
    [self.recorder stopRecording];
    [self.uploader stopUploading];
}

- (void)startIfPossible
{
    if (!self.active) {
        return;
    }

    if (self.lastUploadDate != nil && fabs([self.lastUploadDate timeIntervalSinceNow]) < self.captureInterval) {
        return;
    }

    [self reinitUploader];
    [self.recorder startRecording];
    [self.uploader startUploading];
}

- (void)startCheckTimer
{
    [self invalidateTimer];

    vlt_weakify(self);
    self.checkTimer = [VLTCore timer:VLTDetectorCheckInterval handler:^{
        vlt_strongify(self);
        [self startIfPossible];
    }];
}

- (void)invalidateTimer
{
    if (self.checkTimer != nil) {
        dispatch_source_cancel(self.checkTimer);
        self.checkTimer = nil;
    }
}

@end

