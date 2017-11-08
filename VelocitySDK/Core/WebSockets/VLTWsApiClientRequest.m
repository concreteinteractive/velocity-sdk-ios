//
//  VLTWsApiClientRequest.m
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTWsApiClientRequest.h"

@interface VLTWsApiClientRequest ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy) VLTWsApiSuccess success;
@property (nonatomic, copy) VLTWsApiFailure failure;

@end

@implementation VLTWsApiClientRequest

- (instancetype)initWithData:(NSData *)data success:(VLTWsApiSuccess)success failure:(VLTWsApiFailure)failure
{
    self = [super init];
    if (self) {
        _data    = data;
        _success = success;
        _failure = failure;
    }
    return self;
}

@end
