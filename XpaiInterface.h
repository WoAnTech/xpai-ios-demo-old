//
//  XpaiInterface.h
//  Xpai
//
//  Created by Rod Dong on 11-10-9.
//  All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <UIKit/UIKit.h>

//连接服务器的错误返回码
#define FAIL_QUERY_VS   1      //无法获取到Video Server地址
#define FAIL_CONNECT_VS 2      //无法连接到Video Server
#define FAIL_PASSWORD   3      //用户名密码错误
#define FAIL_GET_VS     4      //通过http方式获取Video Server地址失败

//函数的返回值
#define XPAI_OK                                 0
#define XPAI_ERROR_GENERAL                      -1
#define XPAI_ERROR_CANNOT_CONNECT_TO_SERVER     -2
#define XPAI_ERROR_SERVER_DISCONNECTED          -3
#define XPAI_ERROR_CANNOT_TAKE_PHOTO_NOW        -4
#define XPAI_ERROR_PHOTO_NOT_EXIST              -5
#define XPAI_ERROR_CANNOT_DISCONNECT_NOW        -6
#define XPAI_ERROR_PSSERVER_ERROR               -7
#define XPAI_ERROR_CANNOT_RECORD_NOW            -8
#define XPAI_ERROR_CANNOT_ACTIVE_HARDWARE       -9
#define XPAI_ERROR_CANNOT_TAKE_SNAPSHOT_NOW     -10

//直播时传递给视频服务器的参数Key
#define XPAI_OUTPUT_TAG    @"XpaiOutputTag"
#define XPAI_TASK_OPAQUE   @"XpaiTaskOpaque"

/**
 * Following is from apple document.
 *
 * Preset       iPhone 3G        iPhone 3GS        iPhone 4 (Back)        iPhone 4 (Front)
 *
 *  High         No video          640x480             1280x720              640x480
 *            Apple Lossless      3.5 mbps            10.5 mbps             3.5 mbps
 *
 *  VGA                                                640x480               640x480
 *                                                       ??                     ??
 *
 * Medium        No video          480x360             480x360               480x360
 *            Apple Lossless      700 kbps            700 kbps              700 kbps
 *
 *  Low          No video          192x144             192x144               192x144
 *            Apple Lossless      128 kbps            128 kbps              128 kbps
 */
typedef enum ResolutionValue {
    RESOLUTION_LOW    = 0,
    RESOLUTION_MEDIUM ,
    RESOLUTION_VGA    ,
    RESOLUTION_HIGH   ,
    RESOLUTION_PHOTO  ,
    RESOLUTION_352x288,
    RESOLUTION_1280x720,
    RESOLUTION_1920x1080
} ResolutionValue;

//int resArray[8][7];//当客户端集成了cocopads时再集成我们的SDK会报重复定义的错误，客户端在使用时将该定义注释掉即可通过编译

/**
 * 当摄像头工作在不同模式下时，takePhoto函数取得的视频质量完全不同，如果摄像头工作在视频录制模式，即使把分辨
 * 率设到非常高，照片质量仍然非常低，为了支持高清晰度照片拍摄，增加这一类型定义。
 */
typedef enum WorkMode {
    VIDEO_MODE = 0,
    PHOTO_MODE
} WorkMode;

/**
 * RecordMode是录制模式的类型，主要包括四种，其优缺点和功能分别如下：
 *
 *  +-------------------------------------------------------------------------------------------------------------------------------------+
 *  |              RecordMode             | Local Video Quanlity | Online Video Quanlity  |           Delay         | Bandwidth (480*360) |
 *  |-------------------------------------+----------------------+------------------------+-------------------------+---------------------+
 *  | HARDWARE_ENCODER_LOCAL_STORAGE_ONLY |      Excellent       |          NaN           |           NaN           |       NaN           |
 *  |-------------------------------------+----------------------+------------------------+-------------------------+---------------------+
 *  | HARDWARE_ENCODER_WITH_FULL_UPLOAD   |      Excellent       |       Excellent        | 5-8s, and will increase |     700kbps         |
 *  |-------------------------------------+----------------------+------------------------+-------------------------+---------------------+
 *  | HARDWARE_ENCODER_LOW_DELAY          |      Excellent       | Low, depand on network |       5-8s, always      |  depand on network  |
 *  |-------------------------------------+----------------------+------------------------+-------------------------+---------------------+
 *  | HARDWARE_SOFTWARE_ENCODER_LOW_DELAY |      Excellent       | Low, software encoder  |       1-3s, always      |  depand on network  |
 *  +-------------------------------------------------------------------------------------------------------------------------------------+
 */
typedef enum RecordMode {
    HARDWARE_ENCODER_LOCAL_STORAGE_ONLY = 0,    // 启用硬件编码，视频数据不直播，仅保存在本地
    HARDWARE_ENCODER_WITH_FULL_UPLOAD,          // 启用硬件编码，不管网络是否有阻塞，都按照顺序上传完整数据
    HARDWARE_ENCODER_LOW_DELAY,                 // 启用硬件编码，希望在网络阻塞时，能够丢弃数据，尽量让后台获取最新数据
    HARDWARE_SOFTWARE_ENCODER_LOW_DELAY,         // 同时启用硬件和软件编码，硬件编码的数据保存在本地，软编数据发送到后台，增强后台实时性
    HARDWARE_ENCODER_STREAM                     // 启用硬件编码，并利用iOS8特性，将视频数据直接生成流传输到后台
} RecordMode;

typedef enum TransferMode {
    VIDEO_AND_AUDIO = 0,// 视频+音频
    ONLY_VIDEO,         // 仅视频
    ONLY_AUDIO         // 仅音频
} TransferMode;

typedef enum UploadMode {
    UPLOAD_FROM_FILE_BEGIN = 0,                 // 全新上传一个视频文件
    UPLOAD_FROM_RESUME_POINT                    // 断点续传模式
} UploadMode;

typedef enum AudioMode {
    VOICE_CHAT = 0,
    MOVIE_RECORD
}AudioMode;

typedef enum AuthMode {
    CHALLENGE_PASSWORD = 1,                    //加密
    CLEAR_PASSWORD                             //明文
}AuthMode;

typedef enum AudioEncoderType {
    AMR_NB = 1,
    AAC
}AudioEncoderType;

typedef enum VideoMirroredMode {
    NORMAL = 0,                              //正常模式
    MIRRORED                                 //镜像模式，相当于照镜子(拍摄出来的视频画面左右颠倒)
}VideoMirroredMode;

/* callback object */
@interface NSObject (XpaiInterfaceDelegate)
- (void)didConnectToServer;
- (void)failConnectToServer:(int)failCode;
- (void)didStreamIdNotify:(NSString *)streamId;
- (void)didTakePhoto:(NSString *)url;
- (void)didTakeSnapshot:(NSString *)url;
- (void)didUploadPhoto:(NSString *)url fileId:(int)fileId;
- (void)doReceiveMessage:(NSString *)userName msg:(NSString *)message;
- (void)doReceiveAudioMessage:(NSString *)userName msgFile:(NSString *)url;
- (void)didDisconnect;
- (void)didSendToServer:(SInt64)ID sentLen:(UInt64)sentLen currentPoint:(UInt32)currentPoint videoLen:(UInt32)videoLen;
- (void)didCompleteUpload:(SInt64)ID;
- (void)didStreamIdAndLocalFilePathNotify:(NSString*)streamId localFilePath:(NSString*)path;
- (void)didResumeLiveFail:(int)errorCode;
- (void)doTryResumeLive;
- (void)didResumeLiveOk;
@end

@interface XpaiInterface : NSObject {

}

+ (void)setDelegate:(id)dl;
+ (void)initAudioSession:(AudioMode)mode;

/** 
 * cameraPosition: AVCaptureDevicePositionBack AVCaptureDevicePositionFront
 * resolution: RESOLUTION_LOW RESOLUTION_MEDIUM RESOLUTION_HIGH
 * audioSampleRate: 8000 22050 44100
 * focusMode: AVCaptureFocusModeContinuousAutoFocus  AVCaptureFocusModeAutoFocus
 */
+ (void)initRecorder:(AVCaptureDevicePosition)cameraPosition workMode:(WorkMode)workMode resolution:(ResolutionValue)resolution audioSampleRate:(UInt32)audioSampleRate focusMode:(AVCaptureFocusMode)focusMode torchMode:(AVCaptureTorchMode)torchMode glView:(UIView *)glView prevRect:(CGRect)prevRect captureVideoOrientation:(AVCaptureVideoOrientation)captureVideoOrientation;

+ (void)resetRecorder:(AVCaptureDevicePosition)cameraPosition workMode:(WorkMode)workMode resolution:(ResolutionValue)resolution audioSampleRate:(UInt32)audioSampleRate focusMode:(AVCaptureFocusMode)focusMode torchMode:(AVCaptureTorchMode)torchMode captureVideoOrientation:(AVCaptureVideoOrientation)captureVideoOrientation;;
    
+ (AVCaptureSession *)getVideoCaptureSession;
+ (void)startVideoCapture;
+ (void)stopVideoCapture;
+ (void)tapToFocus:(CGPoint)point;
+ (void)zoom:(CGFloat)factor;
+ (void)setFocusMode:(AVCaptureFocusMode)focusMode;

+ (void)setAuthMode:(AuthMode)authMode;
+ (void)connectToServer:(NSString *)h p:(UInt16)p u:(NSString *)u pd:(NSString *)pd svcd:(NSString *)svcd OnUDP:(BOOL)isOnUDP;
+ (void)connectCloud:(NSString *)httpApiUrl u:(NSString *)u pd:(NSString *)pd svcd:(NSString *)svcd;
+ (void)disconnect;
+ (void)setNetworkTimeout:(int)tm;      // 设置网络超时时间，当在tm（秒）内没有心跳，说明网络超时，发出disconnect消息
// 设置直播恢复的超时时间，单位为秒，默认值是30秒(客户端默认开启了自动恢复直播的功能，恢复的超时时间为30s)，如果设置为0则不尝试自动恢复直播
+ (void)setResumeLiveTimeout:(int)tm;
+ (void)setVideoBitRate:(int)bt;
+ (void)setAudioRecorderParams:(AudioEncoderType) aet channels:(int)channels sampleRate:(int)sampleRate audioBitRate:(int)bitRate;
+ (void)transVideoFile:(NSString*)inputFileName startTime:(CGFloat)startTime duration:(CGFloat)duration outputFileName:(NSString*)outputFileName;
+ (void)setNetWorkingAdaptive:(BOOL)isNWAdaptive;
+ (void)setVideoMirroredMode:(VideoMirroredMode)videoMirroredMode;

+ (SInt64)startRecord:(RecordMode)mode TransferMode:(TransferMode)transferMode forceReallyFile:(BOOL)forceReallyFile volume:(float)volume parameters:(NSDictionary *)paras;
+ (void)pauseRecord;
+ (void)resumeRecord;
+ (void)interruptLive;
+ (void)stopRecord;

+ (SInt64)uploadVideoFile:(NSString *)url mode:(UploadMode)mode sId:(NSString *)sId sPath:(NSString *)sPath isRecordDone:(BOOL)isRecordDone;
+ (void)notifyRecordDone:(SInt64)ID;    // 如果uploadVideoFile的isRecordDone是NO，当视频录制完成后，需要通过本函数通知Lib

+ (void)takePhoto;
+ (void)takeSnapshot;
+ (void)uploadPhoto:(NSString *)url;

+ (BOOL)isConnected;
+ (BOOL)isRecording;

+ (SInt64)getCurrentRecordVideoID;
+ (SInt64)getCurrentSendVideoID;

+ (UInt32)getVideoLength:(SInt64)ID;
+ (UInt64)getSentLength:(SInt64)ID;
+ (NSString *)getVideoFileName:(SInt64)ID;
+ (NSString *)getVideoStreamID:(SInt64)ID;
+ (NSString *)getVideoStreamPath:(SInt64)ID;

+ (void)cancelLive:(SInt64)ID;
+ (NSString *)getXpaiLibVersion;

/**
 * audio record
 */
+ (void)initAudioRecorder;
+ (void)startAudioRecord;
+ (NSString *)stopAudioRecord;
+ (void)releaseAudioRecorder;

@end
