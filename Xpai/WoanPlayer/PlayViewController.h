//
//  ViewController.h
//  WoanPlayerDemo
//
//  Created by 北京沃安科技有限公司 on 4/16/14.
//  Copyright (c) 2014 xuming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WoanPlayerInterface.h"
#import <MediaPlayer/MediaPlayer.h>

@interface PlayViewController : SuperViewController<UIAlertViewDelegate>{
    WoanPlayerInterface *player;
    NSTimer *timer;
    
    UIView *showVideoView;
    UIView *controlView;
    UISlider *timeSlider;
    UIButton *playPauseBtn;
    UILabel *curentLabel;
    UILabel *totalLabel;
    UIActivityIndicatorView *indicatorView;
    UIView *playView;
    UIButton *PreBtn;
    UIButton *playNextBtn;
    MPVolumeView *volumeView;
    UIButton *playViewModeBtn;
    UIButton *doneBtn;
}

@property(nonatomic,retain)NSString *videoPath;

@end
