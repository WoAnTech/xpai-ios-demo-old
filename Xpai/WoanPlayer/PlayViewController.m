//
//  ViewController.m
//  WoanPlayerDemo
//
//  Created by 北京沃安科技有限公司 on 4/16/14.
//  Copyright (c) 2014 xuming. All rights reserved.
//

#import "PlayViewController.h"

@interface PlayViewController (){
    
}

@end

@implementation PlayViewController

@synthesize videoPath;

-(void)dealloc
{
//    NSLog(@"PlayViewController dealloc!");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [videoPath release];
    [player release];
    [super dealloc];
}

- (void)addObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onpreparedListener:)
                                                 name:WoanPlayerLoadDidPreparedNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlaybackDidfinish:)
                                                 name:WoanPlayerPlaybackDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onSeekComplete:)
                                                 name:WoanPlayerSeekingDidFinishNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onPlaybackError:)
                                                 name:WoanPlayerPlaybackErrorNotification
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序

    [self addObservers];    
    [self initView];
}

- (void) viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationWillResignActive:(NSNotification*)n
{
    [player stop];
}

//按home键回来继续重新播放，点播可以在退出去的时候先暂停，回来再继续播放，直播则需重新初始化播放器再播放，这里Demo里面是点播地址
- (void)applicationDidBecomeActive:(NSNotification*)n
{
   [self addObservers];
   [self initView];
    //设置播放直播视频的参数，如播放rtmp类型的视频-probesize可设置为200K，可设置-realtime参数,降低延迟
    NSArray *parameters = [NSArray arrayWithObjects:@"-probesize", @"200000", @"-showmode", @"0", @"-realtime", nil];
    //paras 不需要设置时传nil，播放点播视频请传nil
    player = [[WoanPlayerInterface alloc]initWithContentString:self.videoPath parameters:nil];

    //播放器界面
    playView = [player getPlayViewWithFrame:showVideoView.bounds];
    playView.contentMode = UIViewContentModeScaleAspectFit;
    playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [showVideoView addSubview:playView];
    [showVideoView sendSubviewToBack:playView];

    [player prepareToPlay];
}

- (void)viewDidAppear:(BOOL)animated
{
    //设置播放直播视频的参数，如播放rtmp类型的视频-probesize可设置为200K，可设置-realtime参数,降低延迟
    NSArray *parameters = [NSArray arrayWithObjects:@"-probesize", @"200000", @"-realtime", nil];
    //paras 不需要设置时传nil，播放点播视频请传nil
    player = [[WoanPlayerInterface alloc]initWithContentString:self.videoPath parameters:nil];

    //播放器界面
    playView = [player getPlayViewWithFrame:showVideoView.bounds];
    playView.contentMode = UIViewContentModeScaleAspectFit;
    playView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    [showVideoView addSubview:playView];
    [showVideoView sendSubviewToBack:playView];
    
//    [player setShouldAutoPlay:NO];
    [player prepareToPlay];
//    [player play];
    [super viewDidAppear:animated];
}

-(void)initView
{
    showVideoView = [[UIView alloc]initWithFrame:self.view.bounds];
    showVideoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    controlView = [[UIView alloc]initWithFrame:showVideoView.frame];
    controlView.backgroundColor = [UIColor clearColor];
    controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin;
    
    indicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicatorView.frame = CGRectMake(showVideoView.frame.size.width/2-160/2, showVideoView.frame.size.height/2-160/2, 160, 160);
    [indicatorView startAnimating];
    [indicatorView setHidesWhenStopped:YES];
    [controlView addSubview:indicatorView];
    [indicatorView release];
    
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, controlView.frame.size.height - 88, controlView.frame.size.width, 88)];
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
//    bottomView.layer.cornerRadius = 12;
//    bottomView.layer.masksToBounds = YES;
//
//    UIImageView *bottomBackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, bottomView.frame.size.width, bottomView.frame.size.height)];
//    bottomBackImageView.image = [UIImage imageNamed:@"bottomView.png"];
//    [bottomView addSubview:bottomBackImageView];
//    [bottomBackImageView release];
    
    PreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    PreBtn.frame = CGRectMake(showVideoView.frame.size.width/3 -40/2 - 36/2, 4, 40, 40);
    [PreBtn addTarget:self action:@selector(prePlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [PreBtn setImage:[UIImage imageNamed:@"playPreBtn.png"] forState:UIControlStateNormal];
    [bottomView addSubview:PreBtn];
    
    playPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playPauseBtn.frame = CGRectMake(showVideoView.frame.size.width/2-20, 4, 40, 40);
    [playPauseBtn addTarget:self action:@selector(pausePlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [playPauseBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    [bottomView addSubview:playPauseBtn];
    
    playNextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playNextBtn.frame = CGRectMake(showVideoView.frame.size.width-showVideoView.frame.size.width/3, 4, 40, 40);
    [playNextBtn addTarget:self action:@selector(nextPlayAction:) forControlEvents:UIControlEventTouchUpInside];
    [playNextBtn setImage:[UIImage imageNamed:@"playNextBtn.png"] forState:UIControlStateNormal];
    [bottomView addSubview:playNextBtn];
    
    volumeView = [[MPVolumeView alloc]initWithFrame:CGRectMake(20, 55, showVideoView.frame.size.width - 20*2, 23)];
    volumeView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
    [bottomView addSubview:volumeView];
    [volumeView release];
    
    [controlView addSubview:bottomView];
    [bottomView release];
    
    CGRect topViewFrame = CGRectMake(0, 0, controlView.frame.size.width, 44);
    UIView *topView = [[UIView alloc]initWithFrame:topViewFrame];
    topView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin  | UIViewAutoresizingFlexibleBottomMargin;
    
//    UIImageView *topBackImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height)];
//    topBackImageView.image = [UIImage imageNamed:@"topback.png"];
//    [topView addSubview:topBackImageView];
//    [topBackImageView release];
    
    doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    doneBtn.frame = CGRectMake(6, 7, 45, 30);
    [doneBtn setImage:[UIImage imageNamed:@"backBtn.png"] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(doneAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:doneBtn];
    
    curentLabel = [[UILabel alloc]initWithFrame:CGRectMake(56, 11, 67, 21)];
    curentLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    curentLabel.textColor = [UIColor whiteColor];
    curentLabel.backgroundColor = [UIColor clearColor];
    curentLabel.text = NSLocalizedString(@"00:00:00", @"00:00:00");
    [topView addSubview:curentLabel];
    [curentLabel release];

    totalLabel = [[UILabel alloc]initWithFrame:CGRectMake(showVideoView.frame.size.width-45-3-75, 11, 75, 21)];
    totalLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    totalLabel.textColor = [UIColor whiteColor];
    totalLabel.backgroundColor = [UIColor clearColor];
    totalLabel.text = NSLocalizedString(@"00:00:00", @"00:00:00");
    [topView addSubview:totalLabel];
    [totalLabel release];
    
    playViewModeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    playViewModeBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleBottomMargin;
    playViewModeBtn.frame = CGRectMake(showVideoView.frame.size.width-45, 7, 45, 30);
    [playViewModeBtn setImage:[UIImage imageNamed:@"fillMode.png"] forState:UIControlStateNormal];;
    [playViewModeBtn addTarget:self action:@selector(playViewModeAction:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:playViewModeBtn];
    
    timeSlider = [[UISlider alloc]initWithFrame:CGRectMake(6 + doneBtn.frame.size.width + 5 + curentLabel.frame.size.width + 1, 7, showVideoView.frame.size.width - 6 - doneBtn.frame.size.width - 5 -curentLabel.frame.size.width - 1 - totalLabel.frame.size.width - 3 - playViewModeBtn.frame.size.width, 29)];
    [timeSlider addTarget:self action:@selector(timeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [timeSlider addTarget:self action:@selector(onDragSlideDone:) forControlEvents:UIControlEventTouchUpInside];
    [timeSlider addTarget:self action:@selector(onDragSlideStart:) forControlEvents:UIControlEventTouchDown];
    [topView addSubview:timeSlider];
    [timeSlider release];
    
    [controlView addSubview:topView];
    [topView release];
    
    [showVideoView addSubview:controlView];
    [controlView release];
    
    showVideoView.userInteractionEnabled = YES;
    [self.view addSubview:showVideoView];
    [showVideoView release];
    
}

- (void) onpreparedListener: (NSNotification*)aNotification
{
    showVideoView.userInteractionEnabled = YES;
    //视频文件完成初始化，开始播放视频并启动刷新timer。
    [self startTimer];
}

- (void) onPlaybackError: (NSNotification*)aNotification
{
    //播放失败，打印错误码
    showVideoView.userInteractionEnabled = YES;
    ErrorCode error = [aNotification.object intValue];
    NSLog(@"错误码：%d",error);
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"error" message:[NSString stringWithFormat:@"错误码：%d",error] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    dispatch_async(dispatch_get_main_queue(), ^{
        [alert show];
    });
    [alert release];
}

- (void) onPlaybackDidfinish: (NSNotification*)aNotification
{
    [self stopPlayback];
}

- (void)onSeekComplete:(NSNotification*)notification
{
    //开始启动UI刷新
    [self startTimer];
}

- (void)startTimer
{
    //为了保证UI刷新在主线程中完成。
    [self performSelectorOnMainThread:@selector(startTimeroOnMainThread) withObject:nil waitUntilDone:NO];
}
- (void)startTimeroOnMainThread
{
    showVideoView.userInteractionEnabled = YES;
    [indicatorView stopAnimating];
    
    timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerHandler:) userInfo:nil repeats:YES];
}

- (void)timerHandler:(NSTimer*)timer
{
    [self refreshProgress:[player getCurrentPlaybackTime] totalDuration:[player getDuration]];
}

- (void)refreshProgress:(int) currentTime totalDuration:(int)allSecond
{
    
    NSDictionary* dict = [self convertSecond2HourMinuteSecond:currentTime];
    NSString* strPlayedTime = [self getTimeString:dict prefix:@""];
    curentLabel.text = strPlayedTime;
    
    NSDictionary* dictLeft = [self convertSecond2HourMinuteSecond:allSecond - currentTime];
    NSString* strLeft = [self getTimeString:dictLeft prefix:@"-"];
    totalLabel.text = strLeft;
    timeSlider.value = currentTime;
    timeSlider.maximumValue = allSecond;
    
}

- (NSDictionary*)convertSecond2HourMinuteSecond:(int)second
{
    NSMutableDictionary* dict = [[[NSMutableDictionary alloc] init] autorelease];
    
    int hour = 0, minute = 0;
    
    if (second < 0) {
        second = 0;
    }
    
    hour = second / 3600;
    minute = (second - hour * 3600) / 60;
    second = second - hour * 3600 - minute *  60;
    
    [dict setObject:[NSNumber numberWithInt:hour] forKey:@"hour"];
    [dict setObject:[NSNumber numberWithInt:minute] forKey:@"minute"];
    [dict setObject:[NSNumber numberWithInt:second] forKey:@"second"];
    
    return dict;
}

- (NSString*)getTimeString:(NSDictionary*)dict prefix:(NSString*)prefix
{
    int hour = [[dict objectForKey:@"hour"] intValue];
    int minute = [[dict objectForKey:@"minute"] intValue];
    int second = [[dict objectForKey:@"second"] intValue];
    
    NSString* formatter = hour < 10 ? @"0%d" : @"%d";
    NSString* strHour = [NSString stringWithFormat:formatter, hour];
    
    formatter = minute < 10 ? @"0%d" : @"%d";
    NSString* strMinute = [NSString stringWithFormat:formatter, minute];
    
    formatter = second < 10 ? @"0%d" : @"%d";
    NSString* strSecond = [NSString stringWithFormat:formatter, second];
    
    return [NSString stringWithFormat:@"%@%@:%@:%@", prefix, strHour, strMinute, strSecond];
}

-(void)prePlayAction:(id)sender
{
    [self stopTimer];
    if ([player getCurrentPlaybackTime]-20 > 0) {
        [self refreshProgress:[player getCurrentPlaybackTime]-20 totalDuration:[player getDuration]];
        [player seekTo:[player getCurrentPlaybackTime]-20];
    }else{
        [self refreshProgress:0 totalDuration:[player getDuration]];
        [player seekTo:0];
    }
}

- (void)pausePlayAction:(id)sender
{
    if ([player getVideoPlayState] == VideoPlayStatePlaying) {
        [player pause];
        [playPauseBtn setImage:[UIImage imageNamed:@"playBtn.png"] forState:UIControlStateNormal];
    }else{
        [player play];
        [playPauseBtn setImage:[UIImage imageNamed:@"pauseBtn.png"] forState:UIControlStateNormal];
    }
    
}

-(void)nextPlayAction:(id)sender
{
    [self stopTimer];
    if ([player getCurrentPlaybackTime]+20 < [player getDuration]) {
        [self refreshProgress:[player getCurrentPlaybackTime]+20 totalDuration:[player getDuration]];
        [player seekTo:[player getCurrentPlaybackTime]+20];
    }else{
        [self refreshProgress:[player getDuration] totalDuration:[player getDuration]];
        [player seekTo:[player getDuration]];
    }
    
}

- (void)doneAction:(id)sender
{
    [self stopPlayback];
}

-(void)playViewModeAction:(id)sender
{
    UIButton *playViewModeButton = (UIButton *)sender;
    
    if (playView.contentMode == UIViewContentModeScaleAspectFit) {
        playView.contentMode = UIViewContentModeScaleToFill;
        [playViewModeButton setImage:[UIImage imageNamed:@"fitMode.png"] forState:UIControlStateNormal];
    }else{
        playView.contentMode = UIViewContentModeScaleAspectFit;
        [playViewModeButton setImage:[UIImage imageNamed:@"fillMode.png"] forState:UIControlStateNormal];
    }
}

- (void)timeSliderValueChanged:(id)sender
{
    [self refreshProgress:timeSlider.value totalDuration:[player getDuration]];
}

- (void)onDragSlideDone:(id)sender
{
    //实现视频播放位置切换
    [player seekTo:timeSlider.value];
}

- (void)onDragSlideStart:(id)sender
{
    [self stopTimer];
}

- (void)stopPlayback
{
    [self stopTimer];
    [player stop];
    [self dismissModalViewControllerAnimated:NO];
}

- (void)stopTimer
{
    if ([timer isValid])
    {
        [timer invalidate];
    }
    timer = nil;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([controlView isHidden]) {
        controlView.hidden = NO;
    }else{
        controlView.hidden = YES;
    }
}

//-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    [self stopPlayback];
//}
//

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    timeSlider.frame = CGRectMake(6 + doneBtn.frame.size.width + 5 + curentLabel.frame.size.width + 1, 7, showVideoView.frame.size.width - 6 - doneBtn.frame.size.width - 5 -curentLabel.frame.size.width - 1 - totalLabel.frame.size.width - 3 - playViewModeBtn.frame.size.width, 29);
    PreBtn.frame = CGRectMake(showVideoView.frame.size.width/3 -40/2 - 36/2, 4, 40, 40);
    playNextBtn.frame = CGRectMake(showVideoView.frame.size.width-showVideoView.frame.size.width/3, 4, 40, 40);
    playPauseBtn.frame = CGRectMake(showVideoView.frame.size.width/2-20, 4, 40, 40);
    
    indicatorView.frame = CGRectMake(showVideoView.frame.size.width/2-160/2, showVideoView.frame.size.height/2-160/2, 160, 160);
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown;
}

@end
