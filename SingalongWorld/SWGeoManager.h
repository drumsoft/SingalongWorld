//
//  SWGeoManager.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class SWTrack;
@class SWViewController;

@interface SWGeoManager : NSObject <CLLocationManagerDelegate> {
    
}
- (void)startGPSWithController:(SWViewController *)controller;

- (void)searchGeometryByCountry:(NSString *)country andCity:(NSString *)city forTrack:(SWTrack *)track;

@end
