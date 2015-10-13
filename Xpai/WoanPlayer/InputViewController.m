//
//  RootViewController.m
//  WoanPlayerDemo
//
//  Created by 北京沃安科技有限公司 on 4/18/14.
//  Copyright (c) 2014 xuming. All rights reserved.
//

#import "InputViewController.h"
#import "PlayViewController.h"

@interface InputViewController ()

@end

@implementation InputViewController

@synthesize textField;

- (void)dealloc
{
    [textField release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"输入播放地址";
        self.navigationItem.hidesBackButton = YES;
        UIBarButtonItem* leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(backAction:)];
        self.navigationItem.leftBarButtonItem = leftItem;
        [leftItem release];
    }
    return self;
}

- (void)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSString *path = @"http://115.28.33.49:3999/mobile/1-7a6a12c57df0.flv";
    //如果为直播请在播放地址前加上live_,播放器会针对直播做优化处理，对累计延迟进行快进。
    textField.text = path;
}

- (IBAction)playAction:(id)sender
{
    PlayViewController *playVideoView = [[PlayViewController alloc]init];
    playVideoView.videoPath = textField.text;
    [self presentModalViewController:playVideoView animated:NO];
    [playVideoView release];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    UITextField *textFie = (UITextField*)sender;
    [textFie resignFirstResponder];
}

-(BOOL)prefersStatusBarHidden
{
    return NO;
}

@end
