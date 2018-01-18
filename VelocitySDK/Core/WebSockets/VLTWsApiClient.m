//
//  VLTWsApiClient.m
//  VelocitySDK iOS
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTWsApiClient.h"
#import "FifoListQueue.h"
#import "VLTConfig.h"
#import "VLTErrors.h"
#import "VLTMacros.h"
#import "VLTProtobufHelper.h"
#import "VLTUserDataStore.h"
#import "VLTWsApiClientRequest.h"
#import "Velocity.pbobjc.h"

@import SocketRocket;

static NSString *const VLTWsApiClientUrl = @"https://sdk.vlcty.net/api/ws";

@interface VLTWsApiClient () <SRWebSocketDelegate>

@property (nonnull, copy) NSString *authToken;

@property (nonatomic, assign) NSUInteger queueSize;
@property (nonatomic, strong) id<ListQueue> queue;
@property (nonatomic, strong) dispatch_queue_t delegateQueue;

@property (atomic, strong) SRWebSocket *ws;
@property (atomic, assign) BOOL handshakeCompleted;

@property (atomic, assign, getter=isClosed) BOOL closed;
@property (nonatomic, assign) BOOL alreadyOpen;
@property (atomic, copy) void(^closeBlock)(void);

@end

@implementation VLTWsApiClient

- (nonnull instancetype)initWithQueueSize:(NSUInteger)queueSize
{
    self = [super init];
    if (self) {
        _delegateQueue = dispatch_queue_create("net.vlcty.ws.delegate", DISPATCH_QUEUE_SERIAL);
        _queueSize     = queueSize;
        _queue         = [[FifoListQueue alloc] init];
      
        NSURL *url     = [NSURL URLWithString:VLTWsApiClientUrl];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        [request setValue:[VLTConfig userAgent] forHTTPHeaderField:@"User-Agent"];
        _ws = [[SRWebSocket alloc] initWithURLRequest:request];
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
        DLog(@"[Error]: Data received successfully. But data has no handler for it.");
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    [self finishOperationsInQueueWithError:error];
    vlt_invoke_block(self.onError, error);
}

- (void)finishOperationsInQueueWithError:(NSError *)error
{
    while (self.queue.count > 0) {
        VLTWsApiClientRequest *req = [self.queue get];
        vlt_invoke_block(req.failure, error);
    }
}

- (BOOL)isOpen
{
    return self.ws.readyState == SR_OPEN;
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
    NSError *error = [NSError errorWithDomain:VLTErrorDomain
                                         code:VLTWsApiClientDisconnectedError
                                     userInfo:@{
                                                VLTWsCloseWithCodeKey: @(code),
                                                VLTWsCloseWasCleanKey: @(wasClean),
                                                }];
    [self finishOperationsInQueueWithError:error];
    vlt_invoke_block(self.onError, error);
    webSocket.delegate = nil;
    if (self.closeBlock != nil) {
        self.closeBlock();
    }
}

- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload
{
    vlt_invoke_block(self.onPong, pongPayload);
}

#pragma mark -

- (void)openWithAuthToken:(nonnull NSString *)authToken
{
    @synchronized(self) {
        if (self.alreadyOpen) {
            NSDictionary *uInfo = @{ NSLocalizedDescriptionKey: @"Already tried to open websocket.", };
            NSError *error = [NSError errorWithDomain:VLTErrorDomain code:VLTWsApiClientAlreadyOpenError userInfo:uInfo];
            vlt_invoke_block(self.onError, error);
            return;
        }
        self.alreadyOpen = true;
    }
    self.authToken = authToken;
    [self.ws open];
}

- (void)close
{
    self.onOpen = nil;
    self.onError = nil;
    self.onPong = nil;

    if (self.ws.readyState == SR_CLOSING || self.ws.readyState == SR_CLOSED) {
        return;
    }
    __strong typeof(self) strongSelf = self;
    self.closeBlock = ^{
        strongSelf.closeBlock = nil;
    };
    [self.ws close];
}

- (NSUInteger)handshakeWithSuccess:(nonnull VLTWsApiHandshakeSuccess)success failure:(nonnull VLTWsApiFailure)failure
{
    VLTPBHandshakeRequest *handshakeReq;
    handshakeReq = [VLTProtobufHelper handshakeRequestWithAuthToken:self.authToken
                                                               idfa:[VLTUserDataStore shared].IFA
                                                             userId:[VLTUserDataStore shared].userId];
    NSData *data = [handshakeReq data];
    vlt_weakify(self);
    [self sendData:data
        success:^(NSData *_Nonnull data) {
            NSError *error                   = nil;
            VLTPBHandshakeResponse *response = [[VLTPBHandshakeResponse alloc] initWithData:data error:&error];
            if (!response) {
                vlt_invoke_block(failure, error);
                return;
            }
            vlt_strongify(self);
            self.handshakeCompleted = YES;
            vlt_invoke_block(success, response);
        }
        failure:^(NSError *_Nonnull error) {
            vlt_invoke_block(failure, error);
        }];
    return [data length];
}

- (NSUInteger)motionDetect:(nonnull VLTPBRequest *)request
                   success:(nonnull VLTWsApiRequestSuccess)success
                   failure:(nonnull VLTWsApiFailure)failure
{
    NSData *data = [request data];
    [self sendData:data
        success:^(NSData *_Nonnull data) {
            NSError *error          = nil;
            VLTPBResponse *response = [[VLTPBResponse alloc] initWithData:data error:&error];
            if (!response) {
                vlt_invoke_block(failure, error);
                return;
            }
            vlt_invoke_block(success, response);
        }
        failure:^(NSError *_Nonnull error) {
            vlt_invoke_block(failure, error);
        }];
    return [data length];
}

- (NSUInteger)captureUpload:(nonnull VLTPBRequest *)request
                    success:(nonnull VLTWsApiRequestSuccess)success
                    failure:(nonnull VLTWsApiFailure)failure
{
    request.modelNamesArray = [NSMutableArray new];
    NSData *data            = [request data];
    [self sendData:data
        success:^(NSData *_Nonnull data) {
            NSError *error          = nil;
            VLTPBResponse *response = [[VLTPBResponse alloc] initWithData:data error:&error];
            if (!response) {
                vlt_invoke_block(failure, error);
                return;
            }
            vlt_invoke_block(success, response);
        }
        failure:^(NSError *_Nonnull error) {
            vlt_invoke_block(failure, error);
        }];
    return [data length];
}

- (void)sendData:(NSData *)data success:(VLTWsApiSuccess)success failure:(VLTWsApiFailure)failure
{
    if (self.queue.count > self.queueSize) {
        NSError *error = [NSError errorWithDomain:VLTErrorDomain code:VLTWsApiQueueIsFullError userInfo:nil];
        [self webSocket:self.ws didFailWithError:error];
        return;
    }

    if ([self.ws readyState] != SR_OPEN) {
        NSError *error = [NSError errorWithDomain:VLTErrorDomain code:VLTWsApiClientDisconnectedError userInfo:nil];
        failure(error);
        return;
    }

    VLTWsApiClientRequest *req = [[VLTWsApiClientRequest alloc] initWithData:data success:success failure:failure];
    [self.queue add:req];
    NSError *error = nil;
    BOOL ok = [self.ws sendData:data error:&error];
    if (!ok) {
        [self.queue get];
        failure(error);
    }
}

@end
