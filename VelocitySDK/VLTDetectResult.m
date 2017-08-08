//
//  VLTDetectResult.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 08/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTDetectResult.h"

NSString * const VLTDetectResultWalkingKey = @"walking";
NSString * const VLTDetectResultDrivingKey = @"driving";

@interface VLTDetectResult ()

@property (nonatomic, getter=isWalking) BOOL walking;
@property (nonatomic, getter=isDriving) BOOL driving;

@end

@implementation VLTDetectResult

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict
{
    self = [super init];
    if (self) {
        _walking = dict[VLTDetectResultWalkingKey] ?: false;
        _driving = dict[VLTDetectResultDrivingKey] ?: false;
    }
    return self;
}

@end
