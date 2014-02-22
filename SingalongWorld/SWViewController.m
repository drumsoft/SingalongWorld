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
    
    [self textFieldDidEndEditing:titleTextField];
    [self textFieldDidEndEditing:filterTextField];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// --------------------------------------------------------- textFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self startSearch:textField];
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
    for ( SWTrack *track in tracksArray) {
        if ( [track isReady] ) {
            double dx = track.latitude - latDegree;
            double dy = (track.longitude - lngDegree) * cos( (track.latitude+latDegree)*2*M_PI/(2*360) );
            
            track.direction = atan2(dx, dy) - direction * (2*M_PI) / 360;
            track.distance = sqrt(dx*dx + dy*dy);
            
            [track setPan: sin(track.direction)
                andVolume: 0.25 * cos(track.direction) + 0.30 ];
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
    tracksArray = [[NSMutableArray alloc] init];
}

@end
