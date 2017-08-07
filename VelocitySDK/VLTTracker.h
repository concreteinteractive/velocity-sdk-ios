//
//  VLTTracker.h
//  Velocity
//
//  Created by Vytautas Galaunia on 22/01/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VLTTracker : NSObject

+ (void)activate;
+ (void)deactivate;
+ (BOOL)isActive;
+ (void)setOnStatusHandler:(void(^)(BOOL active))handler;

@end
