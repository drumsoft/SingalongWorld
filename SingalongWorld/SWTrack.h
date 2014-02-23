//
//  SWTrack.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/23.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
/*
 This file is part of Singalong World.
 
 Singalong World is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 Singalong World is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with Singalong World.  If not, see <http://www.gnu.org/licenses/>.
 */

#import <Foundation/Foundation.h>

@class SWGeoManager;
@class SWSoundCloud;

@interface SWTrack : NSObject {
    SWSoundCloud *soundCloud;
    SWGeoManager *geoManager;
    long long track_id;
    double latitude, longitude, direction, distance, y, z;
    NSString *parmanentUrl, *title, *userName, *country, *city, *imageUrl;
    UIImageView *imageview;
}
@property (nonatomic) long long track_id;
@property (nonatomic) double latitude, longitude, direction, distance, y, z;
@property (nonatomic, copy) NSString *parmanentUrl, *title, *userName, *country, *city, *imageUrl;
@property (nonatomic, retain) UIImageView *imageview;

- (id)initWithTrackInfo:(NSDictionary *)trackInfo withSoundCloud:(SWSoundCloud *)sc withGeoManager:(SWGeoManager *)gm;

- (void)setUserDetailInfo:(NSDictionary *)userDetailInfo;
- (void)setLatitude:(double)latDegree longitude:(double)lngDegree distance:(double)dstLength;
- (void)setSoundData:(NSData *)soundData;

- (void)setPan:(double)p andVolume:(double)v;

- (BOOL)isReady;
- (void)stop;

@end
