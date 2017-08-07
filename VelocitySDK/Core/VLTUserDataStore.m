//
//  VLTUserData.m
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 04/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import "VLTUserDataStore.h"

@implementation VLTUserDataStore

+ (nonnull instancetype)shared
{
    static VLTUserDataStore *sharedUserDataStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedUserDataStore = [[VLTUserDataStore alloc] init];
    });
    return sharedUserDataStore;
}

@end
