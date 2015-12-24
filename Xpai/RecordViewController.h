//
//  RecordViewController.h
//  Xpai
//
//  Created by 徐功伟 on 13-04-01.
//  Copyright 2011年 沃安科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVAudioPlayer.h>
#import "XpaiInterface.h"

typedef enum ConnectionMode {
    CONNECT_CLOUD = 0,
    CONNECT_PRIVATE_CLOUD,
    CONNECT_VIDEO_SERVER
} ConnectionMode;

@interface RecordViewController : SuperViewController <AVAudioPlayerDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    BOOL _isConnected;//是否已连接视频服务器
    BOOL _isCapturing;//是否已初始化captureSession
    BOOL _isRecording;//是否开始直播
    BOOL _isLocalRecording;//是否开始本地录制
    BOOL _isOpenRecordMode;//是否打开视频模式预览画面
    BOOL _isOpenPhotoMode;//是否打开图像模式预览画面
    BOOL _isStartAudioRecord;//是否开始音频录制
    BOOL _isPauseRecord;//是否暂停离线录制
    AVCaptureVideoPreviewLayer  *_prevLayer;//预览层
    SInt64  currentID;//当前拍摄视频id（本地）
    AVAudioPlayer *player;
    AVCaptureVideoOrientation currentVideoOrientation;//设备拍摄方向
    AVCaptureDevicePosition currentCameraPosition;//摄像头
    BOOL _isTcpPort;//是否是连接Tcp端口
    int _failCode;//错误码
}

@property(nonatomic,retain)NSString *_fileName;//照片路径（本地）
@property(nonatomic,retain)NSString *currentStreamId;//当前视频流id（服务器）
@property(nonatomic,retain)NSString *currentStreamPath;//当前视频流路径（服务器）
@property(nonatomic,retain)NSString *currentFileName;//当前视频路径（本地）
@property(nonatomic,retain)IBOutlet UIButton *localRecordBtn;
@property(nonatomic,retain)IBOutlet UILabel *label;//信息显示区域
@property(nonatomic,retain)IBOutlet UITextField *ip;//视频服务器ip地址
@property(nonatomic,retain)IBOutlet UITextField *port;//视频服务器端口号
@property (retain, nonatomic) IBOutlet UITextField *service_code;
@property (retain, nonatomic) IBOutlet UITextField *userName;
@property (retain, nonatomic) IBOutlet UITextField *passWord;
@property (strong, nonatomic) IBOutlet UIPickerView *pickerView;
@property (retain, nonatomic) IBOutlet UISwitch *tcpSwitch;
@property (retain, nonatomic) IBOutlet UILabel *tcpLabel;
@property(nonatomic,retain)NSArray *connectTypes;

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)logoutButtonPressed:(id)sender;
- (IBAction)previewPhotoButtonPressed:(id)sender;
- (IBAction)previewButtonPressed:(id)sender;
- (IBAction)startLiveButtonPressed:(id)sender;
- (IBAction)stopLiveButtonPressed:(id)sender;
- (IBAction)startRecordButtonPressed:(id)sender;
- (IBAction)stopRecordButtonPressed:(id)sender;
- (IBAction)takePhotoPressed:(id)sender;
- (IBAction)uploadPressed:(id)sender;
- (IBAction)terminalLiveButtonPressed:(id)sender;
- (IBAction)resumeLiveButtonPressed:(id)sender;
- (IBAction)startAuidoRecord:(id)sender;
- (IBAction)stopAuidoRecord:(id)sender;
- (IBAction)textFieldDoneEditing:(id)sender;
- (IBAction)stopPreView:(id)sender;
- (IBAction)toggleTCP:(id)sender;

-(IBAction)pinch:(UIPinchGestureRecognizer *)recognizer;
@end
