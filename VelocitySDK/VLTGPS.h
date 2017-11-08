//
//  VLTGPS.h
//  VelocitySDK
//
//
//  Copyright © 2017 VLCTY, Inc. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>

extern NSString *_Nonnull const VLTGPSLocationUpdateNotification;
extern NSString *_Nonnull const VLTGPSLocationsKey;

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
