//
//  SWViewController.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import "SWViewController.h"

#import "SWSoundCloud.h"
#import "SWGeoManager.h"
#import "SWTrack.h"

@interface SWViewController () {
    SWGeoManager *geoManager;
    SWSoundCloud *soundCloud;
    NSMutableArray *tracksArray;
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
    [self startSearch:titleTextField];
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
    
    [self resetTracks];
    [soundCloud searchTitle:searchTitle withFilter:searchFilter forController:self];
}

// soundCloud searchTitle から呼ばれて、検索結果の Track を登録
- (void)addTrackWithTrackInfo:(NSDictionary *)trackInfo {
    SWTrack *track = [[SWTrack alloc] initWithTrackInfo:trackInfo withSoundCloud:soundCloud withGeoManager:geoManager];
    [tracksArray addObject:track];
}

// 方向転換によって状態を更新する
- (void)updateDirection:(double)direction fromLatitude:(double)latDegree andLongitude:(double)lngDegree {
    double maxVolume = 0, selectedPan = 0;
    SWTrack *selected = nil;
    
    // 方向の再計算
    for ( SWTrack *track in tracksArray) {
        if ( [track isReady] ) {
            double dx = track.latitude - latDegree;
            double dy = (track.longitude - lngDegree) * cos( (track.latitude+latDegree)*2*M_PI/(2*360) );
            
            track.direction = atan2(dx, dy) - direction * (2*M_PI) / 360;
            track.distance = sqrt(dx*dx + dy*dy);
            
            double pan = sin(track.direction);
            double volume = 0.30 * cos(track.direction) + 0.30;
            
            [track setPan: pan andVolume: volume ];
            
            if ( volume > maxVolume ) {
                selected = track;
                selectedPan = pan;
                maxVolume = volume;
            }
        }
    }
    
    // フォーカスの処理
    if ( selected && fabs(selectedPan) < 0.15 ) {
        // ラベルの書き換え
        statusLabel.text = [NSString stringWithFormat:@"%@ by %@ (%@, %@)",
                            selected.title, selected.userName, selected.city, selected.country];
        statusLabel.textColor = [UIColor whiteColor];
    } else {
        statusLabel.text = @"";
    }
}


// --------------------------------------------------------- local utilities

// テキストフィールドの設定(改行キーを完了ボタン化, デリゲート先決定)
- (void)setUptextField:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyDone;
    [textField setDelegate:self];
}

- (void)resetTracks {
    for (SWTrack *track in tracksArray) {
        [track stop];
    }
    tracksArray = [[NSMutableArray alloc] init];
}

@end
