//
//  SettingConfig.m
//  系统里的配置信息， 包括用户信息， 视频参数信息等。
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import "SettingConfig.h"
#import "XpaiInterface.h"

@implementation SettingConfig

static SettingConfig *_gSettingConfig = nil;

@synthesize _isNotFirst;
@synthesize _videoResolution;
@synthesize _recordMode;
@synthesize _volume;
@synthesize _videoServerIP;
@synthesize _videoServerPort;
@synthesize _service_code;

- (void)dealloc
{
    [_videoServerIP release];
    [_videoServerPort release];
    [_service_code release];
    [super dealloc];
}

+ (SettingConfig*)sharedInstance
{
	if (_gSettingConfig == nil) {
		_gSettingConfig = [[SettingConfig alloc] init];
	}
	return _gSettingConfig;	
}

//加载文件
- (BOOL)LoadDataFromFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _volume = [defaults floatForKey:kVolume];
    _isNotFirst = [defaults boolForKey:kNotFirst];
    _videoResolution = [defaults integerForKey:kVideoResolution];
    _recordMode = [defaults integerForKey:kVideoRecordMode];
    _videoServerIP = [defaults stringForKey:kVideoServerIP];
    _videoServerPort = [defaults stringForKey:kVideoServerPort];
    _service_code = [defaults stringForKey:KSERVICECODE];
    
    if(_isNotFirst==NO)
    {
        _videoResolution = RESOLUTION_MEDIUM;
        _recordMode = HARDWARE_ENCODER_WITH_FULL_UPLOAD;
        [self WriteDataToFile];
    }
    return YES;
}

//写入数据到文件
- (BOOL)WriteDataToFile
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setBool:YES forKey:kNotFirst];
    [defaults setFloat:_volume forKey:kVolume];
    [defaults setInteger:_videoResolution forKey:kVideoResolution];
    [defaults setInteger:_recordMode forKey:kVideoRecordMode];
    [defaults setObject:_videoServerIP forKey:kVideoServerIP];
    [defaults setObject:_videoServerPort forKey:kVideoServerPort];
    [defaults setObject:_service_code forKey:KSERVICECODE];
    [defaults synchronize];
    return YES;
}

@end
