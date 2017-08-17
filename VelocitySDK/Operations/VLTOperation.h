//
//  VLTOperation.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 16/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTPBDetectMotionRequest;

@interface VLTOperation : NSOperation

- (void)markAsExecuting;
- (void)markAsFinished;

@end
