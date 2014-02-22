//
//  SWTrack.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/23.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

#import "SWTrack.h"

#import "SWSoundCloud.h"
#import "SWGeoManager.h"


@interface SWTrack () {
    bool isSoundReady, isUserInfoReady, isGeoReady, isAllPrepared;
    AVAudioPlayer *player;
}
- (void)checkPrepareing;
@end


@implementation SWTrack

@synthesize track_id;
@synthesize latitude, longitude, direction, distance, zoom;
@synthesize parmanentUrl, title, userName, country, city, imageUrl;

- (id)initWithTrackInfo:(NSDictionary *)trackInfo withSoundCloud:(SWSoundCloud *)sc withGeoManager:(SWGeoManager *)gm {
    [super self];
    
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
    
    if ( ! country ) country = @"";
    if ( ! city ) city = @"";
    
    isUserInfoReady = true;
    
    [geoManager searchGeometryByCountry:country andCity:city forTrack:self];
}

- (void)setLatitude:(double)latDegree longitude:(double)lngDegree {
    self.latitude  = latDegree;
    self.longitude = lngDegree;
    
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

@end
