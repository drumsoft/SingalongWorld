//
//  SWSoundCloud.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SWTrack;
@class SWViewController;

@interface SWSoundCloud : NSObject {
    
}

+ (SWSoundCloud *)instance;

- (void)start;

- (BOOL)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter forController:(SWViewController *)controller;

- (void)startFetchUserDetail:(long long)user_id forTrack:(SWTrack *)track;
- (void)startDownStream:(NSString *)url forTrack:(SWTrack *)track;


@end
