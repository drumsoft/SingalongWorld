//
//  SWSoundCloud.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

#import "SWSoundCloud.h"
#import "SCUI.h"

#define SW_SOUNDCLOUD_CLIENT_ID     @"80b083d0d4d07a1cf3bbd93e169fbd51"
#define SW_SOUNDCLOUD_CLIENT_SECRET @"8ec0042d5d2846fef4b2e6bdddce4d09"

SWSoundCloud* SWSoundCloud_me;

@interface SWSoundCloud () {
    SCAccount *account;
    NSString *prevQuery;
    NSMutableDictionary *playerDict;
    NSMutableDictionary *metadataDict;
}
- (NSString *)normalizeText:(NSString *)text;
- (void)startDownStream:(NSString *)url forId:(id) track_id;
- (void)startFetchUserDetail:(id)user_id forId:(id)track_id;

- (void)resetDicts;
@end

@implementation SWSoundCloud

+ (SWSoundCloud *)instance {
    if ( SWSoundCloud_me == nil ) {
        SWSoundCloud_me = [[SWSoundCloud alloc] init];
    }
    return SWSoundCloud_me;
}

- (void)start {
    [SCSoundCloud  setClientID: SW_SOUNDCLOUD_CLIENT_ID
                        secret: SW_SOUNDCLOUD_CLIENT_SECRET
                   redirectURL:[NSURL URLWithString:@""]];
    prevQuery = @"";
    
//    account = [SCSoundCloud account];
}

- (void)startDownStream:(NSString *)url forId:(id)track_id {
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:@{ @"client_id":SW_SOUNDCLOUD_CLIENT_ID }
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 if ( error ) {
                     NSLog(@"Stream error: - %@ - %@", [error localizedDescription], response);
                 } else {
                     NSError *playerError;
                     AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithData:data error:&playerError];
                     [player prepareToPlay];
                     player.numberOfLoops = -1;
                     player.pan    =  -1 +   2 * ((float)rand() / (float)RAND_MAX);
                     player.volume = 0.1 + 0.4 * ((float)rand() / (float)RAND_MAX);
                     [player play];
                     [playerDict setValue:player forKey:track_id];
                 }
             }];
}

- (void)startFetchUserDetail:(id)user_id forId:(id)track_id {
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:
                              [NSString stringWithFormat:@"https://api.soundcloud.com/users/%d.json", [user_id intValue]]
                              ]
             usingParameters:@{ @"client_id":SW_SOUNDCLOUD_CLIENT_ID }
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"User detail error: - %@ - %@", [error localizedDescription], response);
                 } else {
                     // JSONパース->データセット
                     NSError *jsonError = nil;
                     NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                          JSONObjectWithData:data
                                                          options:0
                                                          error:&jsonError];
                     if (!jsonError) {
                         //NSLog(@"User Detail: %@", jsonResponse);
                         NSLog(@"avatar_url : %@", [jsonResponse valueForKey:@"avatar_url"]);
                         NSLog(@"city : %@", [jsonResponse valueForKey:@"city"]);
                         NSLog(@"country : %@", [jsonResponse valueForKey:@"country"]);
                     } else {
                         NSLog(@"json parse error: - %@ - %@", jsonResponse, jsonError);
                     }
                 }
             }];
}

- (BOOL)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter {
    NSString *qTitle = [self normalizeText:searchTitle];
    NSString *qFilter = [self normalizeText:searchFilter];
    NSString *query = [NSString stringWithFormat:@"%@ %@", qTitle, qFilter];
    
    if ( [prevQuery isEqualToString:query] ) return NO;
    
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks.json"]
             usingParameters:@{ @"q": query, @"client_id":SW_SOUNDCLOUD_CLIENT_ID }
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                 // Handle the response
                 if (error) {
                     NSLog(@"Track search error: - %@ - %@", [error localizedDescription], response);
                 } else {
                     // JSONパース->データセット
                     NSError *jsonError = nil;
                     NSJSONSerialization *jsonResponse = [NSJSONSerialization
                                                          JSONObjectWithData:data
                                                          options:0
                                                          error:&jsonError];
                     if (!jsonError && [jsonResponse isKindOfClass:[NSArray class]]) {
                         // NSLog(@"result: %@", jsonResponse);
                         // 検索した名前でフィルタ
                         NSArray *result = [(NSArray *)jsonResponse filteredArrayUsingPredicate:
                                            [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings){
                             NSString *titleNormalized = [self normalizeText:[evaluatedObject valueForKey:@"title"]];
                             return ([titleNormalized rangeOfString:qTitle ].location != NSNotFound) &&
                                    ([titleNormalized rangeOfString:qFilter].location != NSNotFound);
                         }]
                                            ];
                         NSLog(@"result: %d / %d", [result count], [(NSArray *)jsonResponse count] );
                         // 前回の実行をリセット
                         [self resetDicts];
                         // メタデータを保存
                         for(NSDictionary *track in result){
                             [metadataDict setValue:track forKey:[track valueForKey:@"id"]];
                         }
                         // ユーザデータDL開始
                         for(NSDictionary *track in result){
                             [self startFetchUserDetail:[track valueForKey:@"user_id"] forId:[track valueForKey:@"id"]];
                         }
                         // 音声データDL開始
                         for(NSDictionary *track in result){
                             NSLog(@"%@", [track valueForKey:@"title"]);
                             [self startDownStream:[track valueForKey:@"stream_url"] forId:[track valueForKey:@"id"]];
                         }
                     } else {
                         NSLog(@"json parse error: - %@ - %@", jsonResponse, jsonError);
                     }
                 }
             }];
    
    prevQuery = query;
    return YES;
}
- (void)getTrack:(NSNumber *)track_id {
    
}
- (void)getUser:(NSNumber *)user_id {
    
}

// テキストの正規化
- (NSString *)normalizeText:(NSString *)text {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"[ \r\n\t]+" options:0 error:nil];
    text = [text lowercaseString];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    text = [regexp stringByReplacingMatchesInString: text options:0 range:NSMakeRange(0,text.length) withTemplate:@" "];
    return text;
}

// 辞書をリセット
- (void)resetDicts {
    for ( AVAudioPlayer *player in [playerDict objectEnumerator]) {
        if ( [player isPlaying] ) [player stop];
    }
    playerDict = [[NSMutableDictionary alloc] init];
    metadataDict = [[NSMutableDictionary alloc] init];
}

@end
