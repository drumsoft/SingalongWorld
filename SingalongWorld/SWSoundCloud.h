//
//  SWSoundCloud.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SWSoundCloud : NSObject {
    
}

+ (SWSoundCloud *)instance;

- (void)start;
- (BOOL)searchTitle:(NSString *)searchTitle withFilter:(NSString *)searchFilter;
- (void)getTrack:(NSNumber *)track_id;
- (void)getUser:(NSNumber *)user_id;

@end
