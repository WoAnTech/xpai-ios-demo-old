//
//  WoanPlayerLibrary.h
//  WoanPlayerLibrary
//
//  Created by 北京沃安科技有限公司 on 4/1/14.
//  Copyright (c) 2014 xuming. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define WoanPlayerPlaybackDidFinishNotification @"PlaybackDidFinish"
#define WoanPlayerLoadDidPreparedNotification   @"LoadDidPrepared"
#define WoanPlayerPlaybackErrorNotification     @"PlaybackError"
#define WoanPlayerSeekingDidFinishNotification  @"SeekingDidFinish"


//错误码
typedef enum{
    ERROR_INVALID_INPUTFILE = 301, //无效的视频文件地址
    ERROR_NO_SUPPORT_CODEC  //视频编码格式不支持
} ErrorCode;

//播放状态
typedef enum {
    VideoPlayStatePlaying = 10000,
    VideoPlayStatePause,
    VideoPlayStateStop
} VideoPlayState;

@interface WoanPlayerInterface : NSObject

- (id)initWithContentString:(NSString *)contentString parameters:(NSArray *)paras;
- (UIView *)getPlayViewWithFrame:(CGRect)frame;
- (void)setShouldAutoPlay:(BOOL)shouldAutoPlay;
- (void)prepareToPlay;
- (void)play;
- (void)pause;
- (void)stop;
- (void)seekTo:(NSTimeInterval)newPos;

- (NSTimeInterval)getDuration;
- (NSTimeInterval)getCurrentPlaybackTime;
- (VideoPlayState)getVideoPlayState;
- (UIImage*)captureImage;
+ (NSString *)getWoanPlayerLibVersion;
@end
