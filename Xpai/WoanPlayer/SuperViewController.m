//
//  SuperViewController.m
//  Xpai
//
//  Created by 北京沃安科技有限公司 on 5/28/14.
//  Copyright (c) 2014 B-Star. All rights reserved.
//

#import "SuperViewController.h"

@interface SuperViewController ()

@end

@implementation SuperViewController

- (void)viewWillAppear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].statusBarHidden = NO;
}

- (void)viewDidAppear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}
- (void)viewDidDisappear:(BOOL)animated
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

#pragma mark - 控制旋转

- (BOOL)shouldAutorotate {
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation == UIInterfaceOrientationLandscapeRight;
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
