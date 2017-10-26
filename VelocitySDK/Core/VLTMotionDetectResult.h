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
extern NSString * _Nonnull const VLTMotionDetectResultParkedKey;

@interface VLTMotionDetectResult : NSObject

@property (nonatomic, readonly, nonnull) NSDate *timestamp;
@property (nonatomic, readonly, getter=isWalking) BOOL walking;
@property (nonatomic, readonly, getter=isDriving) BOOL driving;
@property (nonatomic, readonly, getter=isParked) BOOL parked;

- (nonnull instancetype)initWithDictionary:(nonnull NSDictionary *)dict;
- (nonnull instancetype)initWithWalking:(BOOL)walking driving:(BOOL)driving parked:(BOOL)parked;
- (nonnull NSDictionary *)toDictionary;

@end
