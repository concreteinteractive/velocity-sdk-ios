//
//  VLTWsApiClientRequest.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 20/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VLTWsApiClient.h"

@interface VLTWsApiClientRequest : NSObject

@property (nonatomic, strong, readonly) NSData *data;
@property (nonatomic, assign, readonly) BOOL withResponse;
@property (nonatomic, copy, readonly)  VLTWsApiSuccess success;
@property (nonatomic, copy, readonly)  VLTWsApiFailure failure;

- (instancetype)initWithData:(NSData *)data success:(VLTWsApiSuccess)success failure:(VLTWsApiFailure)failure;

@end
