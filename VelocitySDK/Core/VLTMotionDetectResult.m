//
//  VLTMotionDetectResult.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTMotionDetectResult.h"

NSString * const VLTMotionDetectResultWalkingKey = @"walking";
NSString * const VLTMotionDetectResultDrivingKey = @"driving";

@interface VLTMotionDetectResult ()

@property (nonatomic, getter=isWalking) BOOL walking;
@property (nonatomic, getter=isDriving) BOOL driving;

@end

@implementation VLTMotionDetectResult

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _walking = dict[VLTMotionDetectResultWalkingKey] ?: false;
        _driving = dict[VLTMotionDetectResultDrivingKey] ?: false;
    }
    return self;
}

@end
