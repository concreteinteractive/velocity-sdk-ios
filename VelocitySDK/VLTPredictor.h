//
//  VLTPredictor.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTPredictor : NSObject

+ (void)activate;
+ (void)deactivate;
+ (BOOL)isActive;
+ (void)setOnStatusHandler:(void(^)(NSArray<NSString *> *predictions))handler;

@end
