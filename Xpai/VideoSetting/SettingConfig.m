//
//  SettingConfig.m
//  系统里的配置信息， 包括用户信息， 视频参数信息等。
//
//  Created by xuming on 13-09-27.
//  Copyright (c) 2013年 沃安科技 . All rights reserved.
//

#import "SettingConfig.h"
#import "XpaiInterface.h"
#import "RecordViewController.h"

@implementation SettingConfig

static SettingConfig *_gSettingConfig = nil;

@synthesize _isNotFirst;
@synthesize _videoResolution;
@synthesize _recordMode;
@synthesize _volume;
@synthesize _videoBitrate;
@synthesize _videoServerIP;
@synthesize _getCloudVSUrl;
@synthesize _getPrivateCloudVSUrl;
@synthesize _videoServerPort;
@synthesize _service_code;
@synthesize _connectionMode;

- (void)dealloc
{
    [_videoServerIP release];
    [_getCloudVSUrl release];
    [_getPrivateCloudVSUrl release];
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
    _getCloudVSUrl = [defaults stringForKey:kGetCloudVSUrl];
    _getPrivateCloudVSUrl = [defaults stringForKey:kGetPrivateCloudVSUrl];
    _videoServerPort = [defaults stringForKey:kVideoServerPort];
    _service_code = [defaults stringForKey:KSERVICECODE];
    _connectionMode = [defaults integerForKey:kConnectionMode];
    _videoBitrate = [defaults integerForKey:kVideoBitrate];
    
    if(_isNotFirst==NO)
    {
         float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
        _videoResolution = RESOLUTION_MEDIUM;
        _videoBitrate = 480;
        if (systemVersion < 8) {
            _recordMode = HARDWARE_SOFTWARE_ENCODER_LOW_DELAY;
        } else {
            _recordMode = HARDWARE_ENCODER_STREAM;
        }
        _connectionMode = CONNECT_CLOUD;
        _getCloudVSUrl = @"http://c.zhiboyun.com/api/20140928/get_vs";
        _getPrivateCloudVSUrl = @"http://192.168.1.100/api/20140928/get_vs";
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
    [defaults setFloat:_videoBitrate forKey:kVideoBitrate];
    [defaults setInteger:_videoResolution forKey:kVideoResolution];
    [defaults setInteger:_recordMode forKey:kVideoRecordMode];
    [defaults setObject:_videoServerIP forKey:kVideoServerIP];
    [defaults setObject:_getCloudVSUrl forKey:kGetCloudVSUrl];
    [defaults setObject:_getPrivateCloudVSUrl forKey:kGetPrivateCloudVSUrl];
    [defaults setObject:_videoServerPort forKey:kVideoServerPort];
    [defaults setObject:_service_code forKey:KSERVICECODE];
    [defaults setInteger:_connectionMode forKey:kConnectionMode];
    [defaults synchronize];
    return YES;
}

@end
