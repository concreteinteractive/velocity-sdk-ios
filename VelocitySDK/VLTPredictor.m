//
//  VLTPredictor.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VLTPredictor.h"
#import "VLTApiClient.h"
#import "VLTConfig.h"
#import "VLTMotionRecorder.h"
#import "VLTTrackingUploader.h"
#import "VLTSensorBuilder.h"
#import "VLTRecordingConfig.h"
#import "VLTErrors.h"
#import "VLTMacros.h"

static const NSTimeInterval CheckInterval = 120;

@interface VLTPredictor ()

@property (atomic, strong) id <VLTMotionRecorder> recorder;
@property (atomic, assign, getter=isActive) BOOL active;
@property (atomic, strong) VLTTrackingUploader *uploader;
@property (atomic, strong) NSTimer *checkTimer;
@property (atomic, copy) void(^onPredictionReceived)(NSArray<NSString *> *predictions);
@property (atomic, strong) NSDate *lastUploadDate;

@property (atomic, assign) NSTimeInterval sampleSize;
@property (atomic, assign) NSTimeInterval captureInterval;

@end

@implementation VLTPredictor

+ (void)activate
{
    [[VLTPredictor shared] updateConfigAndStart:YES];
}

+ (void)deactivate
{
    [[VLTPredictor shared] stop];
}

+ (BOOL)isActive
{
    return [VLTPredictor shared].isActive;
}

+ (void)setOnStatusHandler:(void(^)(NSArray<NSString *> *predictions))handler
{
    [VLTPredictor shared].onPredictionReceived = handler;
}

+ (instancetype)shared
{
    static VLTPredictor *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[VLTPredictor alloc] init];
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
    self.uploader = [[VLTTrackingUploader alloc] initWithRecorder:self.recorder
                                                     impressionId:[[NSUUID UUID] UUIDString]
                                                       sampleSize:self.sampleSize];
    vlt_weakify(self);
    self.uploader.onError = ^(NSError *error) {
        DLog(@"Uploader error: %@", error);
        [weak_self handleError:error];
    };

    self.uploader.onUpload = ^{
        weak_self.lastUploadDate = [NSDate date];
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
                                        if ([config isValid]) {
                                            DLog(@"SDK Config is Valid");
                                            self.sampleSize = config.sampleSize;
                                            self.captureInterval = config.captureInterval;
                                            if (freshStart) {
                                                [self start];
                                            } else {
                                                [self startIfPossible];
                                            }
                                        } else {
                                            DLog(@"SDK Config is Invalid");
                                            vlt_invoke_block(self.onPredictionReceived, nil);
                                        }

                                    } failure:^(NSError *error) {
                                        vlt_strongify(self);
                                        DLog(@"SDK Config get error: %@", error);
                                        vlt_invoke_block(self.onPredictionReceived, nil);
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
    self.checkTimer = [NSTimer timerWithTimeInterval:CheckInterval
                                              target:self
                                            selector:@selector(startIfPossible)
                                            userInfo:nil
                                             repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.checkTimer forMode:NSRunLoopCommonModes];
}

- (void)invalidateTimer
{
    [self.checkTimer invalidate];
    self.checkTimer = nil;
}

@end

