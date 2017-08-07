//
//  VLTSample.m
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import "VLTSimpleSample.h"

@interface VLTSimpleSample ()

@property (nonatomic, assign) NSTimeInterval timestamp;
@property (nonatomic, strong) NSArray <NSNumber *> *values;

@end

@implementation VLTSimpleSample

- (instancetype)init
{
    return [self initWithTimestamp:[[NSDate date] timeIntervalSince1970] x:0 y:0 z:0];
}

- (instancetype)initWithTimestamp:(NSTimeInterval)timestamp x:(float)x y:(float)y z:(float)z
{
    self = [super init];
    if (self) {
        _timestamp = timestamp;
        _values = @[@(x), @(y), @(z)];
    }
    return self;
}

@end
