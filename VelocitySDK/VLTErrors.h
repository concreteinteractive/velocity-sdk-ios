//
//  VLTErrors.h
//  Velocity
//
//  Created by Antanas Majus on 10/25/16.
//  Copyright © 2016 Veloctity. All rights reserved.
//

#ifndef VLTErrors_h
#define VLTErrors_h

enum : NSInteger {
    VLTApiError                             = 1000, // Default api error.
    VLTApiFatalError                        = 1001, // Fatal api error. Stops further motions sensing until app is restarted
    VLTApiTokenNotRecognized                = 1002, // Api token is not recognized. Stops further motions sensing until app is restarted
    VLTApiTokenNoAccess                     = 1003, // Api token doesn't have access or was revoked. Stops further motions sensing until app is restarted
    VLTParseError                           = 1004, // Payload parsing failed. No actions should be taken
    VLTClientError                          = 1005, // An error occured in Velocity client. E.g. it can occur due network error
    VLTApiWsQueueIsFullError                = 1006, // An error, which occurs when websocket API queue reach its limit
};

static NSString * const VLTErrorDomain = @"VLTErrorDomain";

#endif /* VLTErrors_h */
