//
//  SWSoundCloud.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SWTrack.h"
#import "SWSoundCloud.h"
#import "SCUI.h"
#import "SWViewController.h"

#define SW_SOUNDCLOUD_CLIENT_ID     @"80b083d0d4d07a1cf3bbd93e169fbd51"
#define SW_SOUNDCLOUD_CLIENT_SECRET @"8ec0042d5d2846fef4b2e6bdddce4d09"

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

- (BOOL)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter forController:(SWViewController *)controller {
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
                         // メタデータを保存
                         for(NSDictionary *track in result){
                             [controller addTrackWithTrackInfo:track];
                         }
                     } else {
                         NSLog(@"json parse error: - %@ - %@", jsonResponse, jsonError);
                     }
                 }
             }];
    
    prevQuery = query;
    return YES;
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
