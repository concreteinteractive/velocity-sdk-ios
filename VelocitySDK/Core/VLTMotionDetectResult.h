//
//  VLTMotionDetectResult.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 17/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull const VLTMotionDetectResultWalkingKey;
extern NSString * _Nonnull const VLTMotionDetectResultDrivingKey;

@interface VLTMotionDetectResult : NSObject

@property (nonatomic, readonly, getter=isWalking) BOOL walking;
@property (nonatomic, readonly, getter=isDriving) BOOL driving;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;

@end
