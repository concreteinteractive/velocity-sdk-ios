//
//  VLTWsApiClient.h
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 20/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTPBHandshakeResponse;


typedef  void (^VLTWsApiHandshakeSuccess)(VLTPBHandshakeResponse * _Nonnull response);
typedef  void (^VLTWsApiSuccess)(NSData * _Nonnull data);
typedef  void (^VLTWsApiFailure)(NSError * _Nonnull error);

typedef  void (^VLTWsApiOnOpen)(void);
typedef  void (^VLTWsApiOnClose)(NSInteger code, NSString * _Nonnull reason);
typedef  void (^VLTWsApiOnPong)(NSData * _Nullable pongPayload);
typedef  void (^VLTWsApiOnError)(NSError * _Nonnull error);


@interface VLTWsApiClient : NSObject

@property (nonnull, copy, readonly) NSString *authToken;

@property (nonnull, copy) VLTWsApiOnOpen onOpen;
@property (nonnull, copy) VLTWsApiOnClose onClose;
@property (nonnull, copy) VLTWsApiOnPong onPong;
@property (nonnull, copy) VLTWsApiOnError onError;

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                          authToken:(nonnull NSString *)authToken
                          queueSize:(NSUInteger)queueSize;

- (void)open;

- (void)handshakeWithSuccess:(nonnull VLTWsApiHandshakeSuccess)success failure:(nonnull VLTWsApiFailure)failure;

/**
 *  Sends data without response
 */
- (void)sendData:(nonnull NSData *)data;

/**
 *  Sends data and expects to receive a response
 */
- (void)sendData:(nonnull NSData *)data
         success:(nonnull VLTWsApiSuccess)success
         failure:(nonnull VLTWsApiFailure)failure;

@end
