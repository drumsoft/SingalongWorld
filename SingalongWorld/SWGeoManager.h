//
//  SWGeoManager.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface SWGeoManager : NSObject <CLLocationManagerDelegate> {
    
}
- (void)startGPS;

- (void)setGeometryByCountry:(NSString *)country andCity:(NSString *)city forKey:(id)key;
- (void)queryPan:(float *)pan andVolume:(float *)volume forKey:(id)key;

@end
