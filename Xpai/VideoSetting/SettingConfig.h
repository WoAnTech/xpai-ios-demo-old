//
//  SettingConfig.h
//  
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import <Foundation/Foundation.h>

#define kNotFirst				@"NotFirst"
#define kVideoResolution        @"kVideoResolution"
#define kVideoRecordMode        @"VideoRecordMode"
#define kVolume                 @"volume"
#define kVideoServerIP          @"videoServerIP"
#define kVideoServerPort        @"videoServerPort"
#define KSERVICECODE            @"KSERVICECODE"

@interface SettingConfig : NSObject

@property float _volume;//增音大小
@property long _videoResolution;//分辨率
@property long _recordMode;//录制模式
@property BOOL _isNotFirst;//不是第一次运行程序
@property (nonatomic, retain) NSString *_videoServerIP;//视频服务器ip
@property (nonatomic, retain) NSString *_videoServerPort;//视频服务器端口
@property (nonatomic, retain) NSString *_service_code;

+ (SettingConfig*)sharedInstance;
- (BOOL)LoadDataFromFile;
- (BOOL)WriteDataToFile;

@end