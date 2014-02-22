//
//  SWGeoManager.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import "SWGeoManager.h"

#import "SWTrack.h"
#import "SWViewController.h"

#define SW_GEOMANAGER_DEFAULT_LATITUDE   35.670387
#define SW_GEOMANAGER_DEFAULT_LONGITUDE 139.707195

@implementation SWGeoManager {
    SWViewController *viewController;
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

- (void)startGPSWithController:(SWViewController *)controller {
    viewController = controller;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    [locationManager startUpdatingLocation];

    if ([CLLocationManager headingAvailable]) {
        locationManager.headingFilter = 0.2; // 更新頻度(最高)
        locationManager.headingOrientation = CLDeviceOrientationPortrait; // 磁針の先の向き(デバイス背面)
        [locationManager startUpdatingHeading];
    }
}

- (BOOL)isNull:(NSString *)text {
    return !text || text == (id)[NSNull null] || [@"" isEqualToString:text];
}

- (void)setLatitude:(double)latitude longitude:(double)longitude for:(SWTrack *)track {
    double dx = latitude - myLatitude, dy = longitude - myLongitude;
    double distance = sqrt(dx*dx + dy*dy);
    [track setLatitude:latitude longitude:longitude distance:distance];
}

- (void)searchGeometryByCountry:(NSString *)country andCity:(NSString *)city forTrack:(SWTrack *)track {
    long long intKey = track.track_id;
    NSString *query;
    if ( [self isNull:country] ) {
        track.country = @"";
        if ( [self isNull:city] ) {
            track.city = @"";
            [self setLatitude: -90 +  (double)180 * ((double)(intKey % 89) / (double)88)
                    longitude: -180 + (double)360 * ((double)(intKey % 181) / (double)181)
                          for:track];
            return;
        } else {
            query = city;
        }
    } else {
        if ( [self isNull:city] ) {
            track.city = @"";
            query = country;
        } else {
            query = [NSString stringWithFormat:@"%@, %@", city, country];
        }
    }
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString: query
                 completionHandler:^(NSArray* placemarks, NSError* error) {
                     if (!error && [placemarks count] > 0) {
                         CLPlacemark* placemark = placemarks[0];
                         [self setLatitude: placemark.location.coordinate.latitude
                                 longitude: placemark.location.coordinate.longitude
                                       for:track];
                     } else {
                         NSLog(@"Geocoding failed for %@, %@", city, country);
                         [self setLatitude: -90 +  (double)180 * ((double)(intKey % 89) / (double)88)
                                 longitude: -180 + (double)360 * ((double)(intKey % 181) / (double)181)
                                       for:track];
                         track.country = @"";
                         track.city = @"";
                    }
                 }];
}


// ------------------------------------------- CoreLoction delegates
- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *) newLocation fromLocation:(CLLocation *) oldLocation {
    myLatitude  = newLocation.coordinate.latitude;
    myLongitude = newLocation.coordinate.longitude;
}
- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading {
    [viewController updateDirection:newHeading.magneticHeading fromLatitude:myLatitude andLongitude:myLongitude];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog( @"GPS Error : %@", error );
}

@end
