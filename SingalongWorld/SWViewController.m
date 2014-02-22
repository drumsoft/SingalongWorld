//
//  SWViewController.m
//  SingalongWorld
//
//  Created by 片岡 ハルカ on 2014/02/22.
//  Copyright (c) 2014年 drumsoft. All rights reserved.
//

#import "SWViewController.h"

@interface SWViewController () {
    
}
- (void)setUptextField:(UITextField *)textField;
- (NSString *)normalizeText:(NSString *)text;
@end

@implementation SWViewController

// --------------------------------------------------------- UIViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// --------------------------------------------------------- textFieldDelegate
- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self startSearch];
}

// --------------------------------------------------------- public
- (void)startSearch {
    NSString *searchTitle = [self normalizeText:titleTextField.text];
    NSString *searchFilter = [self normalizeText:filterTextField.text];
    
    
    
}

// --------------------------------------------------------- local utilities

// テキストフィールドの設定(改行キーを完了ボタン化, デリゲート先決定)
- (void)setUptextField:(UITextField *)textField {
    textField.returnKeyType = UIReturnKeyDone;
    [textField setDelegate:self];
}

// テキストの正規化
- (NSString *)normalizeText:(NSString *)text {
    NSLog(@"normalizeText is NYI: %@", text);
    return text;
}


@end
