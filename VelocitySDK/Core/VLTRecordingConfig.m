//
//  VLTRecordingConfig.m
//  Velocity
//
//  Created by Vytautas Galaunia on 20/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTRecordingConfig.h"

@interface VLTRecordingConfig ()

@property (nonatomic, assign) NSTimeInterval sampleSize;
@property (nonatomic, assign) NSTimeInterval captureInterval;

@end

@implementation VLTRecordingConfig

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        _sampleSize = [dictionary[@"sample_size"] doubleValue];
        _captureInterval = [dictionary[@"capture_interval"] doubleValue];
    }
    return self;
}

- (BOOL)isValid
{
    return (_sampleSize > 0 && _captureInterval > 0);
}

@end
