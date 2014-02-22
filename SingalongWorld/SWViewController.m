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


@interface SWViewController () {
    SWGeoManager *geoManager;
}
- (void)setUptextField:(UITextField *)textField;
@end

@implementation SWViewController

// --------------------------------------------------------- UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    geoManager = [[SWGeoManager alloc] init];
    [geoManager startGPS];
    
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
    
    [[SWSoundCloud instance] searchTitle:searchTitle withFilter:searchFilter];
}

// --------------------------------------------------------- local utilities

// テキストフィールドの設定(改行キーを完了ボタン化, デリゲート先決定)
- (void)setUptextField:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyDone;
    [textField setDelegate:self];
}


@end
