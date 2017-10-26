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
#import "VLTErrors.h"

@import SocketRocket;

static NSString * const VLTWsApiClientUrl = @"https://sdk.vlcty.net/api/ws";

@interface VLTWsApiClient () <SRWebSocketDelegate>

@property (nonnull, copy) NSString *authToken;

@property (nonatomic, assign) NSUInteger queueSize;
@property (nonatomic, strong) id<ListQueue> queue;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@property (atomic, strong) SRWebSocket *ws;
@property (atomic, assign) BOOL handshakeCompleted;



@property (atomic, assign, getter=isOpen) BOOL open;
@property (atomic, assign, getter=isClosed) BOOL closed;

@end

@implementation VLTWsApiClient

- (nonnull instancetype)initWithQueueSize:(NSUInteger)queueSize
{
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("net.vlcty.ws.delegate", DISPATCH_QUEUE_SERIAL);
        _queueSize = queueSize;
        _queue = [[FifoListQueue alloc] init];
        NSURL *url = [NSURL URLWithString:VLTWsApiClientUrl];
        _ws = [[SRWebSocket alloc] initWithURL:url];
        [_ws setDelegateDispatchQueue:_delegateQueue];
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
    self.open = YES;
    vlt_invoke_block(self.onOpen);
}

- (void)webSocket:(SRWebSocket *)webSocket
 didCloseWithCode:(NSInteger)code
           reason:(NSString *)reason
         wasClean:(BOOL)wasClean
{
    self.closed = YES;
    webSocket.delegate = nil;
    vlt_invoke_block(self.onClose, code, reason);
}

- (void)webSocket:(SRWebSocket *)webSocket
   didReceivePong:(NSData *)pongPayload
{
    vlt_invoke_block(self.onPong, pongPayload);
}

#pragma mark -

- (void)openWithAuthToken:(nonnull NSString *)authToken
{
    self.authToken = authToken;
    [self.ws open];
}

- (void)close
{
    [self.ws close];
}

- (NSUInteger)handshakeWithSuccess:(nonnull VLTWsApiHandshakeSuccess)success
                           failure:(nonnull VLTWsApiFailure)failure
{
    VLTPBHandshakeRequest *handshakeReq;
    handshakeReq = [VLTProtobufHelper handshakeRequestWithAuthToken:self.authToken
                                                               idfa:[VLTConfig IFA]
                                                             userId:[VLTUserDataStore shared].userId];
    NSData *data = [handshakeReq data];
    vlt_weakify(self);
    [self sendData:data
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
    return [data length];
}

- (NSUInteger)motionDetect:(nonnull VLTPBRequest *)request
                   success:(nonnull VLTWsApiRequestSuccess)success
                   failure:(nonnull VLTWsApiFailure)failure
{
    NSData *data = [request data];
    [self sendData:data success:^(NSData * _Nonnull data) {
        NSError *error = nil;
        VLTPBResponse *response = [[VLTPBResponse alloc] initWithData:data error:&error];
        if (!response) {
            vlt_invoke_block(failure, error);
            return;
        }
        vlt_invoke_block(success, response);
    } failure:^(NSError * _Nonnull error) {
        vlt_invoke_block(failure, error);
    }];
    return [data length];
}

- (NSUInteger)captureUpload:(nonnull VLTPBRequest *)request
                    success:(nonnull VLTWsApiRequestSuccess)success
                    failure:(nonnull VLTWsApiFailure)failure
{
    request.modelNamesArray = [NSMutableArray new];
    NSData *data = [request data];
    [self sendData:data
           success:^(NSData * _Nonnull data) {
               NSError *error = nil;
               VLTPBResponse *response = [[VLTPBResponse alloc] initWithData:data error:&error];
               if (!response) {
                   vlt_invoke_block(failure, error);
                   return;
               }
               vlt_invoke_block(success, response);
           } failure:^(NSError * _Nonnull error) {
               vlt_invoke_block(failure, error);
           }];
    return [data length];
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
