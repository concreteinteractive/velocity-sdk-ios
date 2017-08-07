//
//  VLTConfig.m
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTConfig.h"
#import "VLTMacros.h"

static const NSTimeInterval VLTSensorsUpdateInterval = 0.001;
static const NSTimeInterval VLTSensorsBufferSize = 50.0;
static const NSTimeInterval VLTUploadTimeInterval = 3;
static NSString * const VLTLearningModelName = @"Pipeliner Main";

@implementation VLTConfig

+ (NSString *)learningModelName
{
    return VLTLearningModelName;
}

+ (NSTimeInterval)uploadTimeInverval
{
    return VLTUploadTimeInterval;
}

+ (NSTimeInterval)sensorsUpdateInterval
{
    return VLTSensorsUpdateInterval;
}

+ (NSTimeInterval)sensorsBufferSize
{
    return VLTSensorsBufferSize;
}

+ (void)createDirIfNeeded:(NSString *)path
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        return;
    }

    NSError *createError = nil;
    BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:path
                                             withIntermediateDirectories:YES
                                                              attributes:nil
                                                                   error:&createError];
    if (!success) {
        DLog(@"Data dir creation error: %@", createError);
    }
}

+ (NSString *)documentsDirectoryPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths firstObject];
    return path;
}

+ (NSString *)filesDirectoryPath
{
    NSString *path = [[self documentsDirectoryPath] stringByAppendingPathComponent:@"/VLTFiles"];
    [self createDirIfNeeded:path];
    return path;
}

+ (NSString *)modelsDirectoryPath
{
    NSString *path = [[self filesDirectoryPath] stringByAppendingPathComponent:@"/Models"];
    [self createDirIfNeeded:path];
    return path;
}

+ (NSString *)dataDirectoryPath
{
    NSString *path = [[VLTConfig documentsDirectoryPath] stringByAppendingPathComponent:@"/VLTData"];
    [self createDirIfNeeded:path];
    return path;
}

+ (NSURL *)databaseURL
{
    NSString *path = [[self dataDirectoryPath] stringByAppendingPathComponent:@"/vlt.sqlite"];
    return [NSURL fileURLWithPath:path];
}

+ (NSString *)libVersion
{
    NSBundle *bundle = [NSBundle bundleForClass:[VLTConfig class]];
    return [bundle objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
}

+ (NSString *)sessionID
{
    static NSString *sessionID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sessionID = [[NSUUID UUID] UUIDString];
    });
    return sessionID;
}

+ (NSString *)IFA
{
    NSString *ifa = @"00000000-0000-0000-0000-000000000000";
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *uuid = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        ifa = [uuid UUIDString];
    }
    return ifa;
}

+ (BOOL)trackingEnabled
{
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) {
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingTrackingEnabledSelector = NSSelectorFromString(@"isAdvertisingTrackingEnabled");
        BOOL isTrackingEnabled = ((BOOL (*)(id, SEL))[sharedManager methodForSelector:advertisingTrackingEnabledSelector])(sharedManager, advertisingTrackingEnabledSelector);
        if (isTrackingEnabled) {
            return YES;
        }
    }
    return NO;

}

@end
