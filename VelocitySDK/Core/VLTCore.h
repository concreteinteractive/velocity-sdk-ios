//
//  VLTCore.h
//  Velocity
//
//
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTCore : NSObject

+ (NSOperationQueue *)queue;

+ (dispatch_source_t)timer:(NSTimeInterval)interval handler:(dispatch_block_t)handler;

@end
