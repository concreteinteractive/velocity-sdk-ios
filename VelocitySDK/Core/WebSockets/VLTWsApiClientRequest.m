//
//  VLTWsApiClientRequest.m
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 20/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTWsApiClientRequest.h"

@interface VLTWsApiClientRequest ()

@property (nonatomic, strong) NSData *data;
@property (nonatomic, copy)  VLTWsApiSuccess success;
@property (nonatomic, copy)  VLTWsApiFailure failure;

@end

@implementation VLTWsApiClientRequest

- (instancetype)initWithData:(NSData *)data success:(VLTWsApiSuccess)success failure:(VLTWsApiFailure)failure
{
    self = [super init];
    if (self) {
        _data = data;
        _success = success;
        _failure = failure;
    }
    return self;
}

@end
