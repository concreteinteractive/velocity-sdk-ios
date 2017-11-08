//
//  VLTGPS.m
//  VelocitySDK
//
//  
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import "VLTGPS.h"
#import "VLTUserDataStore.h"

NSString * const VLTGPSLocationUpdateNotification = @"VLTGPSLocationUpdateNotification";
NSString * const VLTGPSLocationsKey = @"VLTGPSLocationsKey";

@implementation VLTGPS

+ (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    [[NSNotificationCenter defaultCenter] postNotificationName:VLTGPSLocationUpdateNotification
                                                        object:[self class]
                                                      userInfo:@{
                                                                 VLTGPSLocationsKey : locations,
                                                                 }];
}

+ (BOOL)isEnabled
{
    return [[VLTUserDataStore shared] isGpsEnabled];
}

+ (void)setEnabled:(BOOL)enabled
{
    [VLTUserDataStore shared].gpsEnabled = enabled;
}

@end
