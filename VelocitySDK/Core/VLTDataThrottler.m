//
//  VLTDataThrottler.m
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTDataThrottler.h"
#import <AFNetworking/AFNetworkReachabilityManager.h>

static NSString *const VLTDataThrottlerKey = @"VLTDataThrottlerKey";

@interface VLTDataThrottler ()
@property (nonatomic) NSUInteger bytesCountLimit;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *sentDataDict;
@property (nonatomic) AFNetworkReachabilityManager *reachabilityManager;
@property (nonatomic, readonly) NSString *todaysKey;
@end

@implementation VLTDataThrottler

- (instancetype)initWithLimit:(NSUInteger)bytesCount
          reachabilityManager:(AFNetworkReachabilityManager *)reachabilityManager
{
    self = [super init];
    if (self) {
        self.bytesCountLimit     = bytesCount;
        NSDictionary *storedDict = [[NSUserDefaults standardUserDefaults] dictionaryForKey:VLTDataThrottlerKey];
        self.sentDataDict        = [NSMutableDictionary dictionaryWithDictionary:storedDict];
        self.reachabilityManager = reachabilityManager;
    }
    return self;
}

- (BOOL)shouldThrottle
{
    if (self.reachabilityManager.isReachableViaWWAN) {
        return [self isLimitReached];
    }
    return NO;
}

- (BOOL)isLimitReached
{
    NSUInteger sent = [self.sentDataDict[self.todaysKey] unsignedIntegerValue];
    return sent >= self.bytesCountLimit;
}

- (void)increaseSentDataBy:(NSUInteger)bytesCount
{
    if (!self.reachabilityManager.isReachableViaWWAN) {
        return;
    }

    NSString *todaysKey          = self.todaysKey;
    NSUInteger sentBytesCount    = [self.sentDataDict[todaysKey] unsignedIntegerValue] + bytesCount;
    self.sentDataDict[todaysKey] = @(sentBytesCount);

    for (NSString *key in self.sentDataDict.allKeys) {
        if (![key isEqual:todaysKey]) {
            [self.sentDataDict removeObjectForKey:key];
        }
    }

    [[NSUserDefaults standardUserDefaults] setValue:self.sentDataDict forKey:VLTDataThrottlerKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)todaysKey
{
    return [NSString stringWithFormat:@"%f", self.beginningOfTodayTimestamp];
}

- (NSTimeInterval)beginningOfTodayTimestamp
{
    NSDate *date         = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components =
        [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date];
    return [[calendar dateFromComponents:components] timeIntervalSince1970];
}

@end
