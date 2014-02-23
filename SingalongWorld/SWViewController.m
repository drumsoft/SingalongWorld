//
//  SWViewController.m
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

#import "SWViewController.h"

#import "SWSoundCloud.h"
#import "SWGeoManager.h"
#import "SWTrack.h"

@interface SWViewController () {
    SWGeoManager *geoManager;
    SWSoundCloud *soundCloud;
    NSMutableArray *tracksArray;
    int found, loaded;
}
- (void)setUptextField:(UITextField *)textField;
- (void)resetTracks;
@end

@implementation SWViewController

// --------------------------------------------------------- UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    soundCloud = [SWSoundCloud instance];
    
    geoManager = [[SWGeoManager alloc] init];
    [geoManager startGPSWithController:self];
    
    [self setUptextField:titleTextField];
    [self setUptextField:filterTextField];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// --------------------------------------------------------- textFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

// --------------------------------------------------------- public
- (IBAction)startSearch:(id)sender {
    NSString *searchTitle = titleTextField.text;
    NSString *searchFilter = filterTextField.text;
    
    if ( [soundCloud isChangedSearchTitle:searchTitle andFilter:searchFilter] ) {
        statusLabel.text = @"Start searching...";
        [self resetTracks];
        [soundCloud searchTitle:searchTitle withFilter:searchFilter forController:self];
    }
}

// soundCloud searchTitle から呼ばれて、検索結果の Track を登録
- (void)addTrackWithTrackInfo:(NSDictionary *)trackInfo {
    SWTrack *track = [[SWTrack alloc] initWithTrackInfo:trackInfo withSoundCloud:soundCloud withGeoManager:geoManager];
    [tracksArray addObject:track];
    track.imageview.hidden = true;
    [self.view addSubview:track.imageview];
    
    found++;
    [self updateStatusText];
}

#define SW_SPECIAL_ZOOM_PAN 0.15
#define SW_SPECIAL_ZOOM_Z  20.0
#define SW_3D_XY_ZOOM     400.0
#define SW_3D_MAX_WIDTH  4000.0

double SW_normaeizeDegree(double degree) {
    while ( degree < -180 ) {
        degree += 360;
    }
    while ( 180 < degree ) {
        degree -= 360;
    }
    return degree;
}

// 方向転換によって状態を更新する
- (void)updateDirection:(double)direction fromLatitude:(double)latDegree andLongitude:(double)lngDegree {
    double maxVolume = 0, selectedPan = 0;
    SWTrack *selected = nil;
    int counted_isReady = 0;
    
    // 方向の再計算
    for ( SWTrack *track in tracksArray) {
        if ( [track isReady] ) {
            counted_isReady++;
            double dy = track.latitude - latDegree;
            double dx = SW_normaeizeDegree(track.longitude - lngDegree) * cos( (track.latitude+latDegree)*2*M_PI/(2*360) );
            track.direction = atan2(dx, dy) - direction * (2*M_PI) / 360;
            
            // パンとボリューム
            double pan = sin(track.direction);
            double volume = 0.30 * cos(track.direction) + 0.30;
            [track setPan: pan andVolume: volume ];
            
            // 写真の配置
            track.z  = track.distance * cos(track.direction);
            
            // 最も真ん中のデータ検索
            if ( volume > maxVolume ) {
                selected = track;
                selectedPan = pan;
                maxVolume = volume;
            }
        }
    }
    
    if ( loaded < counted_isReady ) {
        loaded = counted_isReady;
        [self updateStatusText];
    }
    
    // フォーカスの処理
    if ( selected && fabs(selectedPan) < SW_SPECIAL_ZOOM_PAN ) {
        // ラベルの書き換え
        descriptionTextView.text = [NSString stringWithFormat:@"%@ by %@ (%@, %@)",
                            selected.title, selected.userName, selected.city, selected.country];
        descriptionTextView.textColor = [UIColor whiteColor];
        // Z を 最大 20 まで近づける
        double r = (SW_SPECIAL_ZOOM_PAN - fabs(selectedPan)) / SW_SPECIAL_ZOOM_PAN;
        selected.z = r * SW_SPECIAL_ZOOM_Z + (1-r) * selected.z;
    } else {
        descriptionTextView.text = @"";
    }
    
    // z で並び替えして描画を行う
    NSArray *zSorted = [tracksArray sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"z" ascending:YES]]];
    for ( SWTrack *track in zSorted ) {
        if ( track.z >= SW_SPECIAL_ZOOM_PAN ) {
            float x1 = track.distance * sin(track.direction);
            float x2 = 160 + SW_3D_XY_ZOOM * x1 / track.z;
            float y2 = 240 + SW_3D_XY_ZOOM * 7 / track.z;
            float w = SW_3D_MAX_WIDTH / track.z;
            track.imageview.frame = CGRectMake( x2 - w/2, y2 - w/2, w, w );
            [self.view sendSubviewToBack:track.imageview];
            track.imageview.hidden = false;
        } else {
            track.imageview.hidden = true;
        }
    }
}


// --------------------------------------------------------- local utilities

// テキストフィールドの設定(改行キーを完了ボタン化, デリゲート先決定)
- (void)setUptextField:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyDone;
    [textField setDelegate:self];
}

- (void)resetTracks {
    found = 0;
    loaded = 0;
    for (SWTrack *track in tracksArray) {
        [track stop];
    }
    tracksArray = [[NSMutableArray alloc] init];
}

- (void)updateStatusText {
    statusLabel.text = [NSString stringWithFormat:@"loading.. %d / %d.", loaded, found];
}

@end
