//
//  VLTOperation.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTPBDetectMotionRequest;

@interface VLTOperation : NSOperation

- (void)markAsExecuting;
- (void)markAsFinished;

@end
