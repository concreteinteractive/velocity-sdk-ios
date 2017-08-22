//
//  VLTGPS.h
//  VelocitySDK
//
//  Created by Vytautas Galaunia on 10/08/2017.
//  Copyright © 2017 Veloctity. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

extern NSString * _Nonnull const VLTGPSLocationUpdateNotification;
extern NSString * _Nonnull const VLTGPSLocationsKey;

@interface VLTGPS : NSObject

+ (void)locationManager:(nonnull CLLocationManager *)manager
     didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations;

+ (BOOL)isEnabled;
+ (void)setEnabled:(BOOL)enabled;

@end
