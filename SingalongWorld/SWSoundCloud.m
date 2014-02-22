//
//  SWSoundCloud.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import "SWSoundCloud.h"

#import "SCUI.h"

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
    [SCSoundCloud  setClientID:@"80b083d0d4d07a1cf3bbd93e169fbd51"
                        secret:@"8ec0042d5d2846fef4b2e6bdddce4d09"
                   redirectURL:[NSURL URLWithString:@""]];
    prevQuery = @"";
    
    account = [SCSoundCloud account];
}

- (Boolean)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter {
    NSString *qTitle = [self normalizeText:searchTitle];
    NSString *qFilter = [self normalizeText:searchFilter];
    NSString *query = [NSString stringWithFormat:@"%@ %@", qTitle, qFilter];
    
    if ( [prevQuery isEqualToString:query] ) return NO;
    
    id obj = [SCRequest performMethod:SCRequestMethodGET
                           onResource:[NSURL URLWithString:@"https://api.soundcloud.com/tracks"]
                      usingParameters:@{ @"q": query }
                          withAccount:account
               sendingProgressHandler:nil
                      responseHandler:^(NSURLResponse *response, NSData *data, NSError *error){
                          // Handle the response
                          if (error) {
                              NSLog(@"Ooops, something went wrong: %@", [error localizedDescription]);
                          } else {
                              NSLog(@"%@, %@, %@", response, data, error);
                              // Check the statuscode and parse the data
                              // フィルタ->データセット->音声データDL開始
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
    NSLog(@"normalizeText is NYI: %@", text);
    return text;
}

@end
