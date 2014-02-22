//
//  SWViewController.h
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet UITextField *titleTextField;
    __weak IBOutlet UITextField *filterTextField;
    __weak IBOutlet UILabel *statusLabel;
}

- (IBAction)startSearch:(id)sender;

- (void)addTrackWithTrackInfo:(NSDictionary *)trackInfo;

- (void)updateDirection:(double)direction fromLatitude:(double)latDegree andLongitude:(double)lngDegree;

@end
