//
//  VLTCore.m
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTCore.h"
#import <Foundation/Foundation.h>

@implementation VLTCore

+ (dispatch_queue_t)underlyingQueue {
    static dispatch_queue_t underlyingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        underlyingQueue = dispatch_queue_create("net.vlcty.VelocitySDK", DISPATCH_QUEUE_SERIAL);
    });
    return underlyingQueue;
}

+ (NSOperationQueue *)queue
{
    static NSOperationQueue *queue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = [[NSOperationQueue alloc] init];
        [queue setUnderlyingQueue:[self underlyingQueue]];
        [queue setSuspended:false];
    });
    return queue;
}

+ (dispatch_source_t)timer:(NSTimeInterval)interval handler:(dispatch_block_t)handler
{
    uint64_t leeway = (1 * NSEC_PER_SEC) / 10;
    uint64_t timerInterval = interval * NSEC_PER_SEC;
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, [VLTCore underlyingQueue]);
    if (timer)
    {
        dispatch_source_set_timer(timer, dispatch_walltime(NULL, 0), timerInterval, leeway);
        dispatch_source_set_event_handler(timer, handler);
        dispatch_resume(timer);
    }
    return timer;
}

@end
