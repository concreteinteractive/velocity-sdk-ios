//
//  VLTPredictor.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VLTDetectResult;

@interface VLTDetector : NSObject

+ (void)activate;
+ (void)deactivate;
+ (BOOL)isActive;
+ (void)setOnDetectReceivedHandler:(void(^)(VLTDetectResult *))handler;

@end
