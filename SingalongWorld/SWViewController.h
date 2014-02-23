//
//  SWViewController.h
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

@interface SWViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet UITextField *titleTextField;
    __weak IBOutlet UITextField *filterTextField;
    __weak IBOutlet UITextView *statusLabel;
}

- (IBAction)startSearch:(id)sender;

- (void)addTrackWithTrackInfo:(NSDictionary *)trackInfo;

- (void)updateDirection:(double)direction fromLatitude:(double)latDegree andLongitude:(double)lngDegree;

@end
