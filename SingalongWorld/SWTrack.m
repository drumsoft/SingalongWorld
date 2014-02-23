//
//  SWTrack.m
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

#import <AVFoundation/AVFoundation.h>

#import "SWTrack.h"

#import "SWSoundCloud.h"
#import "SWGeoManager.h"

#define SW_3D_TRACK_Y_MAX 5.0


@interface SWTrack () {
    bool isSoundReady, isUserInfoReady, isGeoReady, isAllPrepared;
    AVAudioPlayer *player;
}
- (void)checkPrepareing;
@end


@implementation SWTrack

@synthesize track_id;
@synthesize latitude, longitude, direction, distance, y, z;
@synthesize parmanentUrl, title, userName, country, city, imageUrl;
@synthesize imageview;

- (id)initWithTrackInfo:(NSDictionary *)trackInfo withSoundCloud:(SWSoundCloud *)sc withGeoManager:(SWGeoManager *)gm {
    [super self];
    
    CGRect rect = CGRectMake(160, 240, 100, 100);
    self.imageview = [[UIImageView alloc] initWithFrame:rect];
    
    isSoundReady = false;
    isUserInfoReady = false;
    isGeoReady = false;
    isAllPrepared = false;
    
    soundCloud = sc;
    geoManager = gm;
    
    self.track_id = [[trackInfo valueForKey:@"id"] longLongValue];
    self.parmanentUrl = [trackInfo valueForKey:@"permalink_url"];
    self.title        = [trackInfo valueForKey:@"title"];
    
    [soundCloud startFetchUserDetail:[[trackInfo valueForKey:@"user_id"] longLongValue] forTrack:self];
    [soundCloud startDownStream:[trackInfo valueForKey:@"stream_url"] forTrack:self];

    return self;
}

- (void)setUserDetailInfo:(NSDictionary *)userDetailInfo {
    self.userName = [userDetailInfo valueForKey:@"username"];
    self.imageUrl = [userDetailInfo valueForKey:@"avatar_url"];
    self.country = [userDetailInfo valueForKey:@"country"];
    self.city = [userDetailInfo valueForKey:@"city"];

    isUserInfoReady = true;
    
    [geoManager searchGeometryByCountry:country andCity:city forTrack:self];
    
    NSData *data = [NSData dataWithContentsOfURL: [NSURL URLWithString:self.imageUrl]];
	self.imageview.image = [[UIImage alloc] initWithData:data];
    [self.imageview.superview addSubview:self.imageview];
}

- (void)setLatitude:(double)latDegree longitude:(double)lngDegree distance:(double)dstLength {
    self.latitude  = latDegree;
    self.longitude = lngDegree;
    self.distance  = dstLength;
    
    isGeoReady = true;
    [self checkPrepareing];
}

- (void)setSoundData:(NSData *)soundData {
    NSError *playerError;
    player = [[AVAudioPlayer alloc] initWithData:soundData error:&playerError];
    [player prepareToPlay];
    player.numberOfLoops = -1;
    player.pan    = 0;
    player.volume = 0;
    
    isSoundReady = true;
    [self checkPrepareing];
}

- (void)setPan:(double)p andVolume:(double)v {
    player.pan    = p;
    player.volume = v;
}

- (void)checkPrepareing {
    if ( !isAllPrepared && isSoundReady && isUserInfoReady && isGeoReady ) {
        // 活動開始するとこ
        [player play];
        isAllPrepared = true;
    }
}

- (BOOL)isReady {
    return isAllPrepared;
}

- (void)stop {
    if ([player isPlaying]) {
        [player stop];
    }
    [self.imageview removeFromSuperview];
}


@end
