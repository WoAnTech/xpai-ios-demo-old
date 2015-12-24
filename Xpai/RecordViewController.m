//
//  RecordViewController.m
//  Xpai
//
//  Created by 徐功伟 on 13-04-01.
//  Copyright 2011年 沃安科技. All rights reserved.
//

#import "RecordViewController.h"
#import "SettingConfig.h"

@implementation RecordViewController
@synthesize _fileName,currentFileName,currentStreamId,currentStreamPath;
@synthesize localRecordBtn,label,ip,port;

#pragma mark - View lifecycle
- (void)dealloc
{
    [_fileName release];
    [currentStreamId release];
    [currentStreamPath release];
    [currentFileName release];
    [localRecordBtn release];
    [label release];
    [ip release];
    [port release];
    if (player) {
        [player release];
        player = nil;
    }
    [XpaiInterface disconnect];
    [XpaiInterface setDelegate:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:[UIDevice currentDevice]];
    
    [_service_code release];
    [_userName release];
    [_passWord release];
    [_pickerView release];
    [_connectTypes release];
    [_tcpSwitch release];
    [_tcpLabel release];
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        /* 初始化xpaiManager */
        [XpaiInterface initAudioSession:MOVIE_RECORD];
        [XpaiInterface setDelegate:self];
        /*初始化录音*/
        [XpaiInterface initAudioRecorder];

        /* 初始化三个参数，本示例中不一定会真正用到这些参数，仅仅用于展示功能 */
        _isConnected = NO;
        _isCapturing = NO;
        _isRecording = NO;
        _isOpenRecordMode = NO;
        _isLocalRecording = NO;
        _isOpenPhotoMode = NO;
        _isStartAudioRecord = NO;
        self._fileName = @"";
        self.currentFileName = @"";
        self.currentStreamId = @"";
        self.currentStreamPath = @"";
        currentVideoOrientation = AVCaptureVideoOrientationLandscapeRight;
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    return self;
}

- (void)viewDidLoad
{
    _connectTypes = [[NSArray alloc] initWithObjects:@"直播云", @"私有云", @"视频服务器", nil];
    _pickerView.delegate = self;
    _pickerView.showsSelectionIndicator=YES;
    _pickerView.delegate=self;
    [_pickerView selectRow:[SettingConfig sharedInstance]._connectionMode inComponent:0 animated:YES];
    [self changePickerViewStatus:(int)[SettingConfig sharedInstance]._connectionMode];

    self.service_code.text = [SettingConfig sharedInstance]._service_code;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(deviceOrientationDidChange)
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:[UIDevice currentDevice]];
}

//开始预览封装方法
- (void) startPreview:(WorkMode)mode res:(ResolutionValue)res;
{
    [XpaiInterface setAudioRecorderParams:AAC channels:1 sampleRate:16000 audioBitRate:16000];
    [XpaiInterface initRecorder:currentCameraPosition workMode:mode resolution:res audioSampleRate:22050 focusMode:AVCaptureFocusModeContinuousAutoFocus torchMode:AVCaptureTorchModeOff glView:nil prevRect:self.view.bounds captureVideoOrientation:currentVideoOrientation];
    _prevLayer = [[AVCaptureVideoPreviewLayer layerWithSession:[XpaiInterface getVideoCaptureSession]]retain];
    _prevLayer.frame = self.view.bounds;
    _prevLayer.orientation = currentVideoOrientation;
    _prevLayer.videoGravity = AVLayerVideoGravityResize;//设置该属性修复预览视频画面大小小于播放端视频画面大小的问题
    [self.view.layer insertSublayer:_prevLayer atIndex:0];
    
    [XpaiInterface startVideoCapture];
}
//重设预览参数封装方法
- (void)resetPreview:(WorkMode)mode res:(ResolutionValue)res captureVideoOrientation:(AVCaptureVideoOrientation)captureVideoOrientation;
{
    [XpaiInterface resetRecorder:currentCameraPosition workMode:mode resolution:res audioSampleRate:22050 focusMode:AVCaptureFocusModeContinuousAutoFocus torchMode:AVCaptureTorchModeOff captureVideoOrientation:captureVideoOrientation];
}

#pragma mark - 各按钮事件实现

//连接视频服务器
- (IBAction)loginButtonPressed:(id)sender
{
    if (_isConnected) {
        label.text = @"已登录成功";
        return;
    }
    label.text = @"正在登录中";
    
//    [XpaiInterface setAuthMode:CLEAR_PASSWORD];
    
    //用户名，如服务器没有用户验证，随便传值都行，但不能为nil
    NSString *userName = [NSString stringWithFormat:@"%@",_userName.text];
    //密码，如服务器没有用户验证，随便传值都行，但不能为nil
    NSString *password = [NSString stringWithFormat:@"%@",_passWord.text];
    //授权服务码，可为nil
    NSString *serviceCode = _service_code.text;
    
    if ([SettingConfig sharedInstance]._connectionMode == CONNECT_CLOUD) {//直播云
        [XpaiInterface connectCloud:[SettingConfig sharedInstance]._getCloudVSUrl u:userName pd:password svcd:serviceCode];
    } else if ([SettingConfig sharedInstance]._connectionMode == CONNECT_PRIVATE_CLOUD) {//私有云
        [SettingConfig sharedInstance]._getPrivateCloudVSUrl = ip.text;
        [XpaiInterface connectCloud:ip.text u:userName pd:password svcd:serviceCode];
    } else {//单台视频服务器
        [SettingConfig sharedInstance]._videoServerIP = ip.text;
        [XpaiInterface connectToServer:ip.text p:[port.text intValue] u:userName pd:password svcd:serviceCode OnUDP:!_isTcpPort];
    }

    NSLog(@"%@:%d,%@<%@<%@", ip.text, [port.text intValue],serviceCode,userName,password);
    
    [SettingConfig sharedInstance]._service_code = serviceCode;
    [SettingConfig sharedInstance]._videoServerPort = port.text;
    
    [[SettingConfig sharedInstance] WriteDataToFile];
}
//断开视频服务器
- (IBAction)terminalLiveButtonPressed:(id)sender
{
    if (!_isConnected) {
        NSLog(@"您还没有登陆");
        label.text = @"您还没有登陆";
        return;
    }
    [XpaiInterface disconnect];
}
- (IBAction)logoutButtonPressed:(id)sender
{
    [self dismissModalViewControllerAnimated:NO];
}
//开始预览 拍照模式 分辨率photo
- (IBAction)previewPhotoButtonPressed:(id)sender
{
    if (!_isCapturing)
        [self startPreview:PHOTO_MODE res:RESOLUTION_PHOTO];
    else{
        [self resetPreview:PHOTO_MODE res:RESOLUTION_PHOTO captureVideoOrientation:currentVideoOrientation];
        [self.view.layer insertSublayer:_prevLayer atIndex:0];
        [XpaiInterface startVideoCapture];
    }
    _isOpenRecordMode = NO;
    _isOpenPhotoMode = YES;
    _isCapturing = YES;
}
//开始预览 视频模式
- (IBAction)previewButtonPressed:(id)sender
{
    if (!_isCapturing)
        [self startPreview:VIDEO_MODE res:(int)[SettingConfig sharedInstance]._videoResolution];
    else{
        [self resetPreview:VIDEO_MODE res:(int)[SettingConfig sharedInstance]._videoResolution captureVideoOrientation:currentVideoOrientation];
        [self.view.layer insertSublayer:_prevLayer atIndex:0];
        [XpaiInterface startVideoCapture];
    }
    _isOpenRecordMode = YES;
    _isOpenPhotoMode = NO;
    _isCapturing = YES;
}
//停止预览
- (IBAction)stopPreView:(id)sender
{
    if (!_isCapturing) {
        NSLog(@"请先打开预览模式");
        label.text = @"请先打开预览模式";
        return;
    }
    if (_prevLayer) {
        [_prevLayer removeFromSuperlayer];
    }
    [XpaiInterface stopVideoCapture];
    
    _isCapturing = NO;
    _isOpenRecordMode = NO;
    _isOpenPhotoMode = NO;
}

//是否直连TCP端口
- (IBAction)toggleTCP:(id)sender
{
    if (_isConnected) {
        label.text = @"已登陆成功，无法修改";
        [_tcpSwitch setOn:_isTcpPort animated:TRUE];
        return;
    }
    if ([_tcpSwitch isOn]) {
        _isTcpPort = TRUE;
    } else {
        _isTcpPort = FALSE;
    }
}
//开始直播
- (IBAction)startLiveButtonPressed:(id)sender
{
    if (!_isConnected || !_isOpenRecordMode) {
        NSLog(@"请先登陆并打开视频模式");
        label.text = @"请先登陆并打开视频模式";
        return;
    }
    [XpaiInterface setVideoBitRate:(int)[SettingConfig sharedInstance]._videoBitrate];
    [XpaiInterface setNetWorkingAdaptive:TRUE];//打开网络自适应功能打开
    if (!_isRecording) {
        NSString *sa = [NSString stringWithFormat:@"请大家"];
        sa = [sa stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *paras = [NSDictionary dictionaryWithObjectsAndKeys:sa,XPAI_TASK_OPAQUE,nil,XPAI_OUTPUT_TAG,nil];
        currentID = [XpaiInterface startRecord:(int)[SettingConfig sharedInstance]._recordMode TransferMode:VIDEO_AND_AUDIO forceReallyFile:FALSE volume:[SettingConfig sharedInstance]._volume parameters:paras];
        _isRecording = YES;
        label.text = @"已经开始直播";
        NSLog(@"开始直播");
        NSLog(@"%ld",[SettingConfig sharedInstance]._recordMode); 
    }
}
//结束直播
- (IBAction)stopLiveButtonPressed:(id)sender
{
    if (!_isRecording) {
        NSLog(@"请先开始直播！");
        label.text = @"请先开始直播！";
        return;
    }
    int a = [XpaiInterface getVideoLength:[XpaiInterface getCurrentSendVideoID]];
    NSLog(@"已经结束直播, 视频长度:%d",a);
    [XpaiInterface stopRecord];
    _isRecording = NO;
}
//开始本地录制
- (IBAction)startRecordButtonPressed:(id)sender
{
    if (!_isOpenRecordMode) {
        NSLog(@"请先打开视频模式");
        label.text = @"请先打开视频模式";
        return;
    }
    if (!_isLocalRecording) {
        
        currentID = [XpaiInterface startRecord:HARDWARE_ENCODER_LOCAL_STORAGE_ONLY TransferMode:VIDEO_AND_AUDIO forceReallyFile:TRUE volume:[SettingConfig sharedInstance]._volume parameters:nil];
        _isLocalRecording = YES;
        label.text = @"已经开始本地录制";
        NSLog(@"已经开始本地录制");
        [localRecordBtn setTitle:@"暂停录制" forState:UIControlStateNormal];
        _isPauseRecord = NO;
    }else{
        if (_isPauseRecord) {
            [XpaiInterface resumeRecord];
            _isPauseRecord = NO;
            [localRecordBtn setTitle:@"暂停录制" forState:UIControlStateNormal];
            label.text = @"已经恢复本地录制";
            NSLog(@"已经恢复本地录制");
        }else{
            [XpaiInterface pauseRecord];
            [localRecordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
            _isPauseRecord = YES;
            label.text = @"已经暂停本地录制";
            NSLog(@"已经暂停本地录制");
        }
    }

}
//结束本地录制
- (IBAction)stopRecordButtonPressed:(id)sender
{
    if (!_isLocalRecording) {
        NSLog(@"请先开始录制！");
        label.text = @"请先开始录制！";
        return;
    }
    //本地录制视频在程序tmp目录下可以找到
    label.text = @"已经结束本地录制";
    [XpaiInterface stopRecord];
    _isLocalRecording = NO;
    [localRecordBtn setTitle:@"开始录制" forState:UIControlStateNormal];
    
    self.currentFileName = [XpaiInterface getVideoFileName:currentID];
    NSLog(@"本地视频路径：%@",self.currentFileName);
}
//拍照
- (IBAction)takePhotoPressed:(id)sender
{
    if (!_isOpenPhotoMode) {
        NSLog(@"请先打开图像模式");
        label.text = @"请先打开图像模式";
        return;
    }
    //有声音
    [XpaiInterface takePhoto];
    //视频模式拍照，无声音
//    [XpaiInterface takeSnapshot];
}
//上传本地离线拍摄的视频
- (IBAction)uploadPressed:(id)sender
{
    if (!_isConnected) {
        NSLog(@"您还没有登陆");
        label.text = @"您还没有登陆";
        return;
    }
    //新文件上传
    [XpaiInterface uploadVideoFile:self.currentFileName mode:UPLOAD_FROM_FILE_BEGIN sId:nil sPath:nil isRecordDone:YES];
}
//开始录制音频
- (IBAction)startAuidoRecord:(id)sender
{
    if (!_isStartAudioRecord) {
        label.text = @"开始录制音频";
        NSLog(@"开始录制音频");
        [XpaiInterface startAudioRecord];
        _isStartAudioRecord = YES;
    }
    
}
//结束录制音频
- (IBAction)stopAuidoRecord:(id)sender
{
    if (!_isStartAudioRecord) {
        NSLog(@"请先开始音频");
        label.text = @"请先开始音频";
        return;
    }
    NSString *fileName = [XpaiInterface stopAudioRecord];
    //fileName为本地音频文件路径
    NSLog(@"本地录制音频文件路径: %@", fileName);
    label.text = @"录制音频成功！";
    _isStartAudioRecord = NO;
}
//上传视频文件
- (IBAction)resumeLiveButtonPressed:(id)sender
{
    if (!_isConnected) {
        NSLog(@"您还没有登陆");
        label.text = @"您还没有登陆";
        return;
    }
    //断点续传
    [XpaiInterface uploadVideoFile:self.currentFileName mode:UPLOAD_FROM_RESUME_POINT sId:self.currentStreamId sPath:self.currentStreamPath isRecordDone:YES];
}

- (IBAction)textFieldDoneEditing:(id)sender
{
    UITextField *textFie = (UITextField*)sender;
    [textFie resignFirstResponder];
}

#pragma mark - XpaiInterfaceDelegate 回调函数

//连接视频服务器成功后调用
- (void)didConnectToServer
{
    _isConnected = YES;
    label.text = @"连接视频服务器成功！";
    NSLog(@"连接视频服务器成功！");
}
//连接视频服务器失败后调用
- (void)failConnectToServer:(int)failCode
{
    NSLog(@"连接视频服务器失败！");
    _isConnected = NO;
    _failCode = failCode;
    label.text = [NSString stringWithFormat:@"连接视频服务器失败！，错误码 %d", failCode];
}
//当视频录制开始，并从服务器获取到streamId后，调用该函数，利用这个streamId，可以与webserver进行应用层交互和处理
- (void)didStreamIdNotify:(NSString *)streamId
{
    self.currentStreamId = [XpaiInterface getVideoStreamID:currentID];
    NSLog(@"视频流id:%@",currentStreamId);
    self.currentStreamPath = [XpaiInterface getVideoStreamPath:currentID];
    NSLog(@"视频流路径:%@",self.currentStreamPath);
    self.currentFileName = [XpaiInterface getVideoFileName:currentID];
    NSLog(@"本地文件路径:%@",self.currentFileName);
    // 处理业务层相关业务流程
}
//当拍摄完毕后，将存储在手机文件系统中的图像文件路径返回
- (void)didTakePhoto:(NSString *)url;
{
    label.text = @"拍照成功！";
    NSLog(@"本地照片路径:%@",url);
    self._fileName = url;
}
//无声音拍摄回调
//- (void)didTakeSnapshot:(NSString *)url;
//{
//    self._fileName = url;
//}

//视频服务器成功收到发送的数据时调用
- (void)didSendToServer:(SInt64)ID sentLen:(UInt32)sentLen currentPoint:(UInt32)currentPoint videoLen:(UInt32)videoLen
{
    //视频长度在拍摄过程中为0，停止拍摄后才会得到视频长度
    NSString *toshow = [NSString stringWithFormat:@"发送长度 %U", (unsigned int)sentLen];
    label.text = toshow;
//    NSLog(@"%@",toshow);
}
//停止录制后，当上传完成后调用
- (void)didCompleteUpload:(SInt64)ID
{
    SInt64 abc = ID;
    abc++;
    label.text = @"上传完成";
    NSLog(@"上传完成");
}
//与视频服务器断开连接后调用
- (void)didDisconnect
{
    label.text = _isConnected?@"网络断开":[NSString stringWithFormat:@"连接视频服务器失败！，错误码 %d", _failCode];
    _isConnected = NO;
    if(_isRecording){
        [self stopLiveButtonPressed:nil];
    }
    NSLog(@"网络断开");
}
//收到服务器发送的的文字消息时调用
- (void)doReceiveMessage:(NSString *)userName msg:(NSString *)message
{
    label.text = message;
    NSLog(@"收到文字消息:%@",message);
}
//收到服务器发送的的语音消息时调用
-(void)doReceiveAudioMessage:(NSString *)userName msgFile:(NSString *)url
{
    NSLog(@"收到的音频文件路径:%@", url);
    label.text = url;
    if (player) {
        [player release];
        player = nil;
    }
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:url] error: nil];
    [player play];
    [player setDelegate: self];
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"收到的音频播放结束");
}

-(IBAction)pinch:(UIPinchGestureRecognizer *)recognizer
{
    NSLog(@"%.2f",recognizer.scale);
    [XpaiInterface zoom:recognizer.scale];
}

 //如果拍摄界面支持横竖屏旋转，需要重新设置拍摄方向。一旦拍摄开始后就不能修改。
- (void)deviceOrientationDidChange
{
    /*
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    // Update recording orientation if device changes to portrait or landscape orientation (but not face up/down)
    if ( UIDeviceOrientationIsPortrait( deviceOrientation ) || UIDeviceOrientationIsLandscape( deviceOrientation ) ) {
        currentVideoOrientation = (AVCaptureVideoOrientation)deviceOrientation;
        if(!_isRecording && !_isLocalRecording){
//        [_prevLayer.connection setVideoOrientation:currentVideoOrientation];
            _prevLayer.orientation = currentVideoOrientation;
            [self resetPreview:VIDEO_MODE res:[SettingConfig sharedInstance]._videoResolution captureVideoOrientation:currentVideoOrientation];
        }
    }
    */
}

//几列
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//每列多少行选项
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [_connectTypes count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [_connectTypes objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if (_isConnected) {
        label.text = @"已经登录成功，无法更改连接方式";
        [_pickerView selectRow:[SettingConfig sharedInstance]._connectionMode inComponent:0 animated:YES];
        row = [SettingConfig sharedInstance]._connectionMode;
    }
    //选中了哪一行
    [self changePickerViewStatus:(int)row];
}

- (void)changePickerViewStatus:(int)row
{
    switch (row) {
        case 0:
            ip.text = [SettingConfig sharedInstance]._getCloudVSUrl;
            [ip setBackgroundColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:0.8]];
            [ip setUserInteractionEnabled:FALSE];
            [port setBackgroundColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:0.8]];
            [port setUserInteractionEnabled:FALSE];
            [SettingConfig sharedInstance]._connectionMode = CONNECT_CLOUD;
            [_tcpSwitch setHidden:TRUE];
            [_tcpLabel setHidden:TRUE];
            break;
        case 1:
            ip.text = [SettingConfig sharedInstance]._getPrivateCloudVSUrl;
            [ip setBackgroundColor:NULL];
            [ip setUserInteractionEnabled:TRUE];
            [port setBackgroundColor:[UIColor colorWithRed:100/255.0 green:100/255.0 blue:100/255.0 alpha:0.8]];
            [port setUserInteractionEnabled:FALSE];
            [SettingConfig sharedInstance]._connectionMode = CONNECT_PRIVATE_CLOUD;
            [_tcpSwitch setHidden:TRUE];
            [_tcpLabel setHidden:TRUE];
            break;
        case 2:
            ip.text = [SettingConfig sharedInstance]._videoServerIP;
            port.text = [SettingConfig sharedInstance]._videoServerPort;
            [ip setBackgroundColor:NULL];
            [ip setUserInteractionEnabled:TRUE];
            [port setBackgroundColor:NULL];
            [port setUserInteractionEnabled:TRUE];
            [SettingConfig sharedInstance]._connectionMode = CONNECT_VIDEO_SERVER;
            [_tcpSwitch setHidden:FALSE];
            [_tcpLabel setHidden:FALSE];
            break;
        default:
            break;
    }

}

- (void)viewDidUnload {
    [self setService_code:nil];
    [self setUserName:nil];
    [self setPassWord:nil];
    [super viewDidUnload];
}
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
