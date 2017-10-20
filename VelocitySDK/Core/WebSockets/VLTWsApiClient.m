//
//  VLTWsApiClient.m
//  VelocitySDK iOS
//
//  Created by Vytautas Galaunia on 20/10/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTWsApiClient.h"
#import "FifoListQueue.h"
#import "VLTWsApiClientRequest.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTConfig.h"
#import "VLTUserDataStore.h"
#import "Velocity.pbobjc.h"
#import <SocketRocket/SocketRocket.h>
#import "VLTErrors.h"

@import SocketRocket;

@interface VLTWsApiClient () <SRWebSocketDelegate>

@property (nonnull, copy) NSString *authToken;

@property (nonatomic, assign) NSUInteger queueSize;
@property (nonatomic, strong) id<ListQueue> queue;

@property (atomic, strong) SRWebSocket *ws;
@property (atomic, assign) BOOL handshakeCompleted;

@end

@implementation VLTWsApiClient

- (nonnull instancetype)initWithUrl:(nonnull NSURL *)url
                          authToken:(nonnull NSString *)authToken
                          queueSize:(NSUInteger)queueSize
{
    self = [super init];
    if (self) {
        _authToken = authToken;
        _queueSize = queueSize;
        _queue = [[FifoListQueue alloc] init];
        _ws = [[SRWebSocket alloc] initWithURL:url];
        _ws.delegate = self;
    }
    return self;
}

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    if (self.queue.count > 0) {
        VLTWsApiClientRequest *req = [self.queue get];
        vlt_invoke_block(req.success, message);
    } else {
        DLog(@"[Error]: Data received successfully. But data has no handler for it.")
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    if (self.queue.count > 0) {
        VLTWsApiClientRequest *req = [self.queue get];
        vlt_invoke_block(req.failure, error);
    } else {
        vlt_invoke_block(self.onError, error);
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    vlt_invoke_block(self.onOpen);
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean
{
    vlt_invoke_block(self.onClose, code, reason);
}

- (void)webSocket:(SRWebSocket *)webSocket
   didReceivePong:(NSData *)pongPayload
{
    vlt_invoke_block(self.onPong, pongPayload);
}

#pragma mark -

- (void)open
{
    [self.ws open];
}


- (void)handshakeWithSuccess:(nonnull VLTWsApiHandshakeSuccess)success failure:(nonnull VLTWsApiFailure)failure
{
    VLTPBHandshakeRequest *handshakeReq;
    handshakeReq = [VLTProtobufHelper handshakeRequestWithAuthToken:self.authToken
                                                               idfa:[VLTConfig IFA]
                                                             userId:[VLTUserDataStore shared].userId];
    vlt_weakify(self);
    [self sendData:[handshakeReq data]
           success:^(NSData * _Nonnull data) {
               NSError *error = nil;
               VLTPBHandshakeResponse *response = [[VLTPBHandshakeResponse alloc] initWithData:data error:&error];
               if (!response) {
                   vlt_invoke_block(failure, error);
                   return;
               }

               vlt_strongify(self);
               self.handshakeCompleted = YES;
               vlt_invoke_block(success, response);
           } failure:^(NSError * _Nonnull error) {
               vlt_invoke_block(failure, error);
           }];
}

- (void)sendData:(NSData *)data
{
    [self.ws send:data];
}

- (void)sendData:(NSData *)data
         success:(VLTWsApiSuccess)success
         failure:(VLTWsApiFailure)failure
{
    if (self.queue.count > self.queueSize) {
        NSError *error = [NSError errorWithDomain:VLTErrorDomain code:VLTApiWsQueueIsFullError userInfo:nil];
        [self webSocket:self.ws didFailWithError:error];
        return;
    }
    
    VLTWsApiClientRequest *req = [[VLTWsApiClientRequest alloc] initWithData:data
                                                                     success:success
                                                                     failure:failure];
    [self.queue add:req];
    [self.ws send:data];
}

@end
