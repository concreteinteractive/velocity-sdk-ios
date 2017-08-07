//
//  VLTApiClient.m
//  Velocity
//
//  Created by Antanas Majus on 10/20/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#import <AFNetworking/AFURLSessionManager.h>
#import <AFNetworking/AFHTTPSessionManager.h>

#import "VLTApiClient.h"
#import "Velocity.pb.h"
#import "VLTProtobufHelper.h"
#import "VLTErrors.h"
#import "VLTMacros.h"
#import "VLTRecordingConfig.h"
#import "VLTConfig.h"
#import "VLTCore.h"

static NSString * const VLTApiClientBaseUrl = @"https://sdk.vlcty.net/api/";

static NSString * const VLTAcceptJSONValue = @"application/vnd.sdk.velocity.v1+json";
static NSString * const VLTAcceptProtobufValue = @"application/vnd.sdk.velocity.v1+octet-stream";

static NSString * const SessionIDKey    = @"session_id";
static NSString * const UserIDKey       = @"user_id";
static NSString * const AppIDKey        = @"app_id";
static NSString * const GoalIDKey       = @"goal_id";
static NSString * const EventIDKey      = @"event_id";


typedef NS_ENUM(NSInteger, VLTApiStatusCode) {
    VLTApiStatusCodeUnrecognizedToken = 401,
    VLTApiStatusCodeTokenNoAccess = 403,
};

@interface VLTApiClient()

@property (nonatomic, copy, nonnull) NSString *baseUrl;
@property (nonatomic, copy, nonnull) NSString *apiToken;

@end

@implementation VLTApiClient

+ (VLTApiClient *)shared
{
    static VLTApiClient *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] initWithBaseURLPath:VLTApiClientBaseUrl];
    });

    return sharedInstance;
}

- (instancetype)initWithBaseURLPath:(NSString *)url
{
    NSParameterAssert(url);
    self = [super init];
    if (self) {
        self.baseUrl = url;
    }
    return self;
}

- (void)setApiToken:(NSString *)token
{
    _apiToken = [token copy];
}

- (AFHTTPSessionManager *)jsonManager
{
    NSURL *url = [NSURL URLWithString:self.baseUrl];
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:url];
    [manager setCompletionQueue:[[VLTCore queue] underlyingQueue]];
    manager.requestSerializer = [AFJSONRequestSerializer serializerWithWritingOptions:NSJSONWritingPrettyPrinted];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    return manager;
}

- (void)getConfigWithIFA:(nullable NSString *)ifa
                 success:(nullable void (^)(VLTRecordingConfig * _Nonnull config))success
                 failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    NSDictionary *params = @{
                             SessionIDKey: [VLTConfig sessionID],
                             UserIDKey: ifa,
                             AppIDKey: [[NSBundle mainBundle] bundleIdentifier],
                             };

    NSURLRequest *req = [self jsonRequestWithMethod:@"GET" endpoint:@"motions/config" parameters:params error:nil];
    [[[self jsonManager] dataTaskWithRequest:req
                              uploadProgress:nil
                            downloadProgress:nil
                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                               if (!error) {
                                   VLTRecordingConfig *config = [[VLTRecordingConfig alloc] initWithDictionary:responseObject];
                                   vlt_invoke_block(success, config);
                               } else {
                                   vlt_invoke_block(failure, [self apiErrorFromError:error response:response]);
                               }
                           }] resume];
}

- (void)uploadForTracking:(nonnull VLTPBCapture *)capture
                  success:(nullable void (^)(void))success
                  failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    NSData *data = [capture data];
    NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:sessionConfig];
    [manager setCompletionQueue:[[VLTCore queue] underlyingQueue]];
    manager.responseSerializer = [self protobufResponseSerializer];

    NSDictionary *params = @{SessionIDKey: [VLTConfig sessionID]};
    NSMutableURLRequest *req = [self requestWithMethod:@"POST" endpoint:@"motions/capture/v2" parameters:params error:nil];
    [self setProtobufContentType:req];
    [req setHTTPBody:data];

    [[manager dataTaskWithRequest:req
                   uploadProgress:nil
                 downloadProgress:nil
                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                    if (!error) {
                        vlt_invoke_block(success);
                    } else {
                        vlt_invoke_block(failure, [self apiErrorFromError:error response:response]);
                    }
                }] resume];
}

- (void)markGoalAsCompleted:(nonnull NSString *)goalId
                    eventId:(nonnull NSString *)eventId
                    success:(nullable void (^)(void))success
                    failure:(nullable void (^)(NSError *_Nonnull error))failure
{
    NSDictionary *params = @{
                             GoalIDKey: goalId,
                             EventIDKey: eventId,
                             };

    NSString *endpoint = [NSString stringWithFormat:@"events"];
    NSURLRequest *req = [self jsonRequestWithMethod:@"POST" endpoint:endpoint parameters:params error:nil];
    [[[self jsonManager] dataTaskWithRequest:req
                              uploadProgress:nil
                            downloadProgress:nil
                           completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                               if (!error) {
                                   vlt_invoke_block(success);
                               } else {
                                   vlt_invoke_block(failure, [self apiErrorFromError:error response:response]);
                               }
                           }] resume];
}

- (void)detect:(nonnull VLTPBCapture *)capture
       success:(nullable void (^)(void))success
       failure:(nullable void (^)(NSError *_Nonnull error))failure
{

}

- (NSMutableURLRequest *)jsonRequestWithMethod:(NSString *)method
                                      endpoint:(NSString *)endpoint
                                    parameters:(id)parameters
                                         error:(NSError **)error
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseUrl, endpoint];
    NSMutableURLRequest *req = [[AFJSONRequestSerializer serializer] requestWithMethod:method
                                                                             URLString:urlString
                                                                            parameters:parameters
                                                                                 error:error];
    [self setHeadersForRequest:req];
    return req;

}

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                  endpoint:(NSString *)endpoint
                                parameters:(NSDictionary *)parameters
                                     error:(NSError **)error
{
    NSString *urlString = [NSString stringWithFormat:@"%@%@", self.baseUrl, endpoint];
    NSMutableURLRequest *req = [[AFHTTPRequestSerializer serializer] requestWithMethod:method
                                                                             URLString:urlString
                                                                            parameters:parameters
                                                                                 error:error];
    [self setHeadersForRequest:req];
    return req;
}

- (void)setHeadersForRequest:(NSMutableURLRequest *)request
{
    if (self.apiToken) {
        NSString *tokenField = [NSString stringWithFormat:@"Token token=\"%@\"", self.apiToken];
        [request setValue:tokenField forHTTPHeaderField:@"Authorization"];
    }

    [request setValue:[self userAgent] forHTTPHeaderField:@"User-Agent"];
    [request setValue:[VLTConfig trackingEnabled] ? @"0" : @"1" forHTTPHeaderField:@"DNT"];
    [request setValue:VLTAcceptJSONValue forHTTPHeaderField:@"Accept"];
}

- (void)setProtobufContentType:(NSMutableURLRequest *)request
{
    [request setValue:@"application/octet-stream" forHTTPHeaderField:@"Content-Type"];
    [request setValue:VLTAcceptProtobufValue forHTTPHeaderField:@"Accept"];
}

- (AFHTTPResponseSerializer *)protobufResponseSerializer
{
    AFHTTPResponseSerializer * responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    responseSerializer.acceptableContentTypes = [[NSSet alloc] initWithObjects:@"application/x-protobuf",
                                                                                @"application/json",
                                                                                @"text/html",
                                                                                nil];
    return responseSerializer;
}

- (NSError *)apiErrorFromError:(NSError *)error response:(NSURLResponse *)response
{
    NSError *apiError = [NSError errorWithDomain:VLTErrorDomain
                                            code:[self vltErrorCodeFromResponse:response]
                                        userInfo:error.userInfo];
    return apiError;
}

- (NSInteger)vltErrorCodeFromResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code >= 400 && code < 500) {
            switch (code) {
                case VLTApiStatusCodeUnrecognizedToken:
                    return VLTApiTokenNotRecognized;
                case VLTApiStatusCodeTokenNoAccess:
                    return VLTApiTokenNoAccess;
                default:
                    return VLTApiFatalError;
                    break;
            }
        }
    }
    return VLTApiError;
}

- (NSError *)apiErrorWithMessage:(NSString *)message
{
    NSDictionary *userInfo = @{ NSLocalizedDescriptionKey: message };
    NSError *apiError = [NSError errorWithDomain:VLTErrorDomain
                                            code:VLTApiError
                                        userInfo:userInfo];
    return apiError;
}

- (NSString *)userAgent
{
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)",
                           @"VelocitySDK",
                           [VLTConfig libVersion],
                           [[UIDevice currentDevice] model],
                           [[UIDevice currentDevice] systemVersion],
                           [[UIScreen mainScreen] scale]
                           ];
    return userAgent;
}

@end
