//
//  SWSoundCloud.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
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

#import <UIKit/UIKit.h>

#import "SWTrack.h"
#import "SWSoundCloud.h"
#import "SCUI.h"
#import "SWViewController.h"

// <strike>create your app at http://soundcloud.com/you/apps and copy its Client ID and Client Secret here.</strike>
// We need no Client Secret because this App requires no login to SoundCloud.
#define SW_SOUNDCLOUD_CLIENT_ID     @"e77e730ad93b0ea41550f32b391141d1"
#define SW_SOUNDCLOUD_CLIENT_SECRET @""

SWSoundCloud* SWSoundCloud_me;

@interface SWSoundCloud () {
    SCAccount *account;
    NSString *prevQuery;
}
- (NSString *)normalizeText:(NSString *)text;
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

- (void)startDownStream:(NSString *)url forTrack:(SWTrack *)track {
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:url]
             usingParameters:@{ @"client_id":SW_SOUNDCLOUD_CLIENT_ID }
                 withAccount:nil
      sendingProgressHandler:nil
             responseHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                 if ( error ) {
                     NSLog(@"Stream error: - %@ - %@", [error localizedDescription], response);
                 } else {
                     [track setSoundData:data];
                 }
             }];
}

- (void)startFetchUserDetail:(long long)user_id forTrack:(SWTrack *)track {
    [SCRequest performMethod:SCRequestMethodGET
                  onResource:[NSURL URLWithString:
                              [NSString stringWithFormat:@"https://api.soundcloud.com/users/%lld.json", user_id]
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
                         [track setUserDetailInfo:(NSDictionary *)jsonResponse];
                     } else {
                         NSLog(@"json parse error: - %@ - %@", jsonResponse, jsonError);
                     }
                 }
             }];
}

- (BOOL)isChangedSearchTitle:(NSString *)searchTitle andFilter:(NSString *)searchFilter  {
    NSString *qTitle = [self normalizeText:searchTitle];
    NSString *qFilter = [self normalizeText:searchFilter];
    NSString *query = [NSString stringWithFormat:@"%@ %@", qTitle, qFilter];
    
    return ![prevQuery isEqualToString:query];
}

- (void)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter forController:(SWViewController *)controller {
    NSString *qTitle = [self normalizeText:searchTitle];
    NSString *qFilter = [self normalizeText:searchFilter];
    NSString *query = [NSString stringWithFormat:@"%@ %@", qTitle, qFilter];
    prevQuery = query;
    
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
                                    ([titleNormalized rangeOfString:qFilter].location != NSNotFound) &&
                                    ([evaluatedObject valueForKey:@"stream_url"]) &&
                                    ([evaluatedObject valueForKey:@"streamable"])
                             ;
                         }]
                                            ];
                         NSLog(@"result: %d / %d", [result count], [(NSArray *)jsonResponse count] );
                         // メタデータを保存
                         for(NSDictionary *track in result){
                             [controller addTrackWithTrackInfo:track];
                         }
                     } else {
                         NSLog(@"json parse error: - %@ - %@", jsonResponse, jsonError);
                     }
                 }
             }];
}

// テキストの正規化
- (NSString *)normalizeText:(NSString *)text {
    NSRegularExpression *regexp = [NSRegularExpression regularExpressionWithPattern:@"[ \r\n\t]+" options:0 error:nil];
    text = [text lowercaseString];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    text = [regexp stringByReplacingMatchesInString: text options:0 range:NSMakeRange(0,text.length) withTemplate:@" "];
    return text;
}

@end
