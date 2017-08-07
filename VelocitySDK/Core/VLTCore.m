//
//  VLTCore.m
//  Velocity
//
//  Created by Vytautas Galaunia on 21/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTCore.h"

@implementation VLTCore

+ (dispatch_queue_t)underlyingQueue {
    static dispatch_queue_t underlyingQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        underlyingQueue = dispatch_queue_create("net.vlcty.VelocitySDK", DISPATCH_QUEUE_CONCURRENT);
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

@end
