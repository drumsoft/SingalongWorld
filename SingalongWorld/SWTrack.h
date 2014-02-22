//
//  SWTrack.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/23.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWGeoManager;
@class SWSoundCloud;

@interface SWTrack : NSObject {
    SWSoundCloud *soundCloud;
    SWGeoManager *geoManager;
    long long track_id;
    double latitude, longitude, direction, distance, zoom;
    NSString *parmanentUrl, *title, *userName, *country, *city, *imageUrl;
    UIImageView *imageview;
}
@property (nonatomic) long long track_id;
@property (nonatomic) double latitude, longitude, direction, distance, zoom;
@property (nonatomic, copy) NSString *parmanentUrl, *title, *userName, *country, *city, *imageUrl;
@property (nonatomic, retain) UIImageView *imageview;

- (id)initWithTrackInfo:(NSDictionary *)trackInfo withSoundCloud:(SWSoundCloud *)sc withGeoManager:(SWGeoManager *)gm;

- (void)setUserDetailInfo:(NSDictionary *)userDetailInfo;
- (void)setLatitude:(double)latDegree longitude:(double)lngDegree;
- (void)setSoundData:(NSData *)soundData;

- (void)setPan:(double)p andVolume:(double)v;

- (BOOL)isReady;
- (void)stop;

@end
