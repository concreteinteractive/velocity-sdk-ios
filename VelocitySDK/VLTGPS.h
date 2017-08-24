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


/**
 * @brief A point for GPS intergration, you should invoke it from your delegate of CLLocationManger
 * @param manager Instance of CLLoationManager
 * @param locations List of locations received by CLLocationManager delegate
 **/
+ (void)locationManager:(nonnull CLLocationManager *)manager
     didUpdateLocations:(nonnull NSArray<CLLocation *> *)locations;

/**
 * @brief Returns current state of GPS data collection
 */
+ (BOOL)isEnabled;

/**
 * @brief Enables GPS data collection in SDK
 */
+ (void)setEnabled:(BOOL)enabled;

@end
