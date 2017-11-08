//
//  VLTConfig.h
//  Velocity
//
//  
//  Copyright © 2016 VLCTY, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTConfig : NSObject

+ (NSString *)learningModelName;
+ (NSTimeInterval)uploadTimeInverval;
+ (NSTimeInterval)sensorsUpdateInterval;
+ (NSTimeInterval)sensorsBufferSize;

+ (NSString *)modelsDirectoryPath;
+ (NSString *)dataDirectoryPath;
+ (NSURL *)databaseURL;

+ (NSString *)libVersion;
+ (NSString *)IFA;
+ (NSString *)defaultUserID;
+ (BOOL)trackingEnabled;

@end
