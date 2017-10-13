//
//  VLTDataThrottler.h
//  VelocitySDK
//
//  Created by Antanas Majus on 10/12/17.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFNetworkReachabilityManager;

@interface VLTDataThrottler : NSObject

- (instancetype)initWithLimit:(NSUInteger)bytesCount reachabilityManager:(AFNetworkReachabilityManager *)reachabilityManager;

- (BOOL)shouldThrottle;
- (BOOL)isLimitReached;
- (void)increaseSentDataBy:(NSUInteger)bytesCount;

@end
