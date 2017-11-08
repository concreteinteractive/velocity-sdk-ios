//
//  VLTDataThrottler.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFNetworkReachabilityManager;

@interface VLTDataThrottler : NSObject

- (instancetype)initWithLimit:(NSUInteger)bytesCount
          reachabilityManager:(AFNetworkReachabilityManager *)reachabilityManager;

- (BOOL)shouldThrottle;
- (BOOL)isLimitReached;
- (void)increaseSentDataBy:(NSUInteger)bytesCount;

@end
