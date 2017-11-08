//
//  VLTMotion.m
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import "VLTMotion.h"

@interface VLTMotion()

@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) float weight;

@end

@implementation VLTMotion

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-designated-initializers"
- (instancetype)init
{
    @throw [NSException exceptionWithName:@"NOT_SUPPORTED"
                                   reason:@"PLEASE USE: -initWithName:weight"
                                 userInfo:nil];
}
#pragma clang diagnostic pop

- (instancetype)initWithName:(NSString *)name weight:(float)weight
{
    self = [super init];
    if (self) {
        _name = [name copy];
        _weight = weight;
    }
    return self;
}

@end
