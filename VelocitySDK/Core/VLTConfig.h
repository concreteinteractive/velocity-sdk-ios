//
//  VLTConfig.h
//  Velocity
//
//  Created by Vytautas Galaunia on 20/10/16.
//  Copyright © 2016 Veloctity. All rights reserved.
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
+ (NSString *)sessionID;
+ (BOOL)trackingEnabled;

@end
