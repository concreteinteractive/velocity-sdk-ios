//
//  VLTOperation.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 16/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTOperation.h"
#import "Velocity.pb.h"
#import "VLTMacros.h"

@interface VLTOperation ()

@property (atomic, assign, getter=isOperationExecuting) BOOL operationExecuting;
@property (atomic, assign, getter=isOperationFinished) BOOL operationFinished;

@end

@implementation VLTOperation

- (void)markAsExecuting
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    self.operationExecuting = YES;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
}

- (void)markAsFinished
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    [self willChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
    self.operationExecuting = NO;
    self.operationFinished = YES;
    [self didChangeValueForKey:NSStringFromSelector(@selector(isExecuting))];
    [self didChangeValueForKey:NSStringFromSelector(@selector(isFinished))];
}

- (BOOL)isExecuting
{
    return self.isOperationExecuting;
}

- (BOOL)isFinished
{
    return self.isOperationFinished;
}

@end
