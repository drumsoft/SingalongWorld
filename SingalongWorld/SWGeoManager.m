//
//  SWGeoManager.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import "SWGeoManager.h"

#define SW_GEOMANAGER_DEFAULT_LATITUDE   35.670387
#define SW_GEOMANAGER_DEFAULT_LONGITUDE 139.707195

@implementation SWGeoManager {
    CLLocationManager *locationManager;
    double myLatitude, myLongitude, myDirection;
    NSMutableDictionary *locationDictionary;
}

- (id)init {
    myLatitude  = SW_GEOMANAGER_DEFAULT_LATITUDE;
    myLongitude = SW_GEOMANAGER_DEFAULT_LONGITUDE;
    [self resetDictionary];
    return self;
}

- (void)resetDictionary {
    locationDictionary = [[NSMutableDictionary alloc] init];
}

- (void)startGPS {
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];

    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 0.2; // 更新頻度(最高)
        locationManager.headingOrientation = CLDeviceOrientationPortrait; // 磁針の先の向き(デバイス背面)
        [locationManager startUpdatingHeading];
    }
}

- (void)setGeometryByCountry:(NSString *)country andCity:(NSString *)city forKey:(id)key {
    CLGeocoder *geocoder = [[[CLGeocoder alloc] init] autorelease];
    [geocoder geocodeAddressString:[NSString stringWithFormat:@"%@, %@", city, country]
                 completionHandler:^(NSArray* placemarks, NSError* error) {
                     if (!error && [placemarks count] > 0) {
                         CLPlacemark* placemark = placemarks[0];
                         [locationDictionary setObject:@[
                                                        [NSNumber numberWithDouble:placemark.location.coordinate.latitude],
                                                        [NSNumber numberWithDouble:placemark.location.coordinate.longitude]
                                                        ] forKey:key];
                     } else {
                         NSLog(@"Geocoding failed for %@, %@", city, country);
                         int intKey = [(NSNumber *)key intValue];
                         double latitude  =  -90 +  (double)90 * ((double)(intKey % 89) / (double)88);
                         double longitude = -180 + (double)180 * ((double)(intKey % 181) / (double)181);
                         [locationDictionary setObject:@[
                                                         [NSNumber numberWithDouble:latitude],
                                                         [NSNumber numberWithDouble:longitude]
                                                         ] forKey:key];
                     }
                 }];
}

- (void)queryPan:(float *)pan andVolume:(float *)volume forKey:(id)key {
    NSArray *coodinate = [locationDictionary objectForKey:key];
    if ( coodinate ) {
        double lat = [coodinate[0] doubleValue];
        double lng = [coodinate[0] doubleValue];
        double dx = lat - myLatitude;
        double dy = (lng - myLongitude) * cos( (lat+myLatitude)*2*M_PI/(2*360) );
        double d_rotate = atan2(dx, dy) - myDirection * (2*M_PI) / 360;
        *pan    = sin(d_rotate);
        *volume = 0.25 * cos(d_rotate) + 0.30;
    } else {
        *pan = 0;
        *volume = 0;
    }
}


// ------------------------------------------- CoreLoction delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *) newLocation fromLocation:(CLLocation *) oldLocation {
    myLatitude  = newLocation.coordinate.latitude;
    myLongitude = newLocation.coordinate.longitude;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    myDirection = newHeading.magneticHeading;
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog( @"GPS Error : %@", error );
}

@end
