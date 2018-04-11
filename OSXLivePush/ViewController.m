//
//  ViewController.m
//  OSXLivePush
//
//  Created by zhao on 16/7/22.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import "ViewController.h"
#import "QTFFAVStreamer.h"
#import "NSView+BackgroundColor.h"
#import "QTFFAVConfig.h"

@interface ViewController ()<AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

{
    // av capture objects
    QTFFAVStreamer *_avStreamer;
    
    // state
    BOOL _isStreaming;
}

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view
    _isStreaming = NO;

//    // create the streamer
    _avStreamer = [[QTFFAVStreamer alloc] init];
    
    [self initAVCapture];
}

-(void)initAVCapture
{
    _captureSession=[[AVCaptureSession alloc]init];
    _captureSession.sessionPreset = AVCaptureSessionPreset1280x720;
    NSError *error=nil;
    _captureVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil]; ;
    if (error) {
        NSLog(@"取得设备输入对象时出错，错误原因：%@",error.localizedDescription);
        return;
    }
    else{
        if ([_captureSession canAddInput:_captureVideoInput]) {
            [_captureSession addInput:_captureVideoInput];
        }
        else{
            NSLog(@"添加录屏设备失败");
        }
    }
    
    AVCaptureDeviceInput *audioInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio] error:nil];
    if ([_captureSession canAddInput:audioInput]) {
        [_captureSession addInput:audioInput];
    }
    else{
        NSLog(@"添加音频设备失败");
    }

    
    QTFFAVConfig *config = [QTFFAVConfig sharedConfig];
    
    _captureVideoOutput=[[AVCaptureVideoDataOutput alloc]init];
    NSMutableDictionary *videoSettings = [NSMutableDictionary dictionary];
    
    if (config.videoCaptureSetPixelBufferSize)
    {
        [videoSettings setValue:[NSNumber numberWithDouble:config.videoCapturePixelBufferWidth]
                      forKey:(id)kCVPixelBufferWidthKey];
        
        [videoSettings setValue:[NSNumber numberWithDouble:config.videoCapturePixelBufferHeight]
                      forKey:(id)kCVPixelBufferHeightKey];
    }
    
    if (config.videoCaptureSetPixelBufferFormatType)
    {
        [videoSettings setValue:[NSNumber numberWithUnsignedLong:config.videoCapturePixelBufferFormatType]
                      forKey:(id)kCVPixelBufferPixelFormatTypeKey];
    }
    
    [_captureVideoOutput setVideoSettings:videoSettings];
    
    [_captureVideoOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    if ([_captureSession canAddOutput:_captureVideoOutput]) {
        [_captureSession addOutput:_captureVideoOutput];
    }
    
    _captureAudioOutput=[[AVCaptureAudioDataOutput alloc]init];
    [_captureAudioOutput setSampleBufferDelegate:self queue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
    if ([_captureSession canAddOutput:_captureAudioOutput]) {
        [_captureSession addOutput:_captureAudioOutput];
    }
    
    NSMutableDictionary *audioSettings = [[NSMutableDictionary alloc] init];//录音时所必需的参数设置
    
    [audioSettings setValue:[NSNumber numberWithInteger:kAudioFormatLinearPCM]
                forKey:AVFormatIDKey];
    
    [audioSettings setValue:[NSNumber numberWithFloat:config.audioCodecSampleRate] forKey:AVSampleRateKey];
    
    [audioSettings setValue:[NSNumber numberWithFloat:32] forKey:AVLinearPCMBitDepthKey];
    
    [audioSettings setValue:@(YES) forKey:AVLinearPCMIsFloatKey];
    
    [audioSettings setValue:[NSNumber numberWithInteger:config.audioCodecNumberOfChannels] forKey:AVNumberOfChannelsKey];
     _captureAudioOutput.audioSettings = audioSettings;
    
    
    //创建视频预览层，用于实时展示摄像头状态
    _captureVideoPreviewLayer=[[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
    
    _captureVideoPreviewLayer.frame=self.customView.bounds;
    _captureVideoPreviewLayer.videoGravity=AVLayerVideoGravityResizeAspect;//填充模式
    //将视频预览层添加到界面中
    [self.customView.layer addSublayer:_captureVideoPreviewLayer];
    [_captureSession startRunning];
    
    [_buttonClick setEnabled:YES];

}

- (IBAction)buttonAction:(NSButton *)sender {
    if (_isStreaming)
    {
        [self stopStreaming];
    }
    else
    {
        [self startStreaming];
    }
}

- (void)startStreaming;
{
    if (! _isStreaming)
    {
        // start the stream
        NSLog(@"Starting streaming...");
        
        NSError *error = nil;
        BOOL success = [_avStreamer openStream:&error];
        
        if (success)
        {
            NSLog(@"Streaming started successfully.");
            
            // set UI state
            _buttonClick.title = @"Stop";
            
            // set streaming state
            _isStreaming = YES;
            
        }
        else
        {
            NSLog(@"Stream starting failed with error: %@", [error localizedDescription]);
            _isStreaming = NO;
        }
    }
}

- (void)stopStreaming;
{
    if (_isStreaming)
    {
        NSError *error = nil;
        BOOL success = [_avStreamer closeStream:&error];
        
        if (success)
        {
            NSLog(@"Streaming closed successfully.");
        }
        else
        {
            NSLog(@"Stream closing failed with error: %@", [error localizedDescription]);
        }
        
        // set UI state
        _buttonClick.title = @"Start";
        
        // set streaming state
        _isStreaming = NO;
    }
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate Methods
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if([captureOutput isEqual:_captureVideoOutput]){
//        [_avStreamer streamVideoSampleBuffer:sampleBuffer];
    }
    else if ([captureOutput isEqual:_captureAudioOutput]){
        [_avStreamer streamAudioFrame:sampleBuffer];
    }
}

- (IBAction)typeClick:(NSButton *)sender {
    
    NSLog(@"%@",sender.title);

    [self.captureSession beginConfiguration];
    
    [self.captureSession removeInput:_captureVideoInput];
    
    AVCaptureInput *captureVideoInput;
    if([sender.title isEqualToString:@"录像"]){
        captureVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo] error:nil];
        sender.title = @"录屏";
    }
    else{
        captureVideoInput= [[AVCaptureScreenInput alloc]initWithDisplayID:CGMainDisplayID()] ;
        sender.title = @"录像";
    }
    
    
    if ([self.captureSession canAddInput:captureVideoInput]) {
        [self.captureSession addInput:captureVideoInput];
        _captureVideoInput = captureVideoInput;
    }
    else{
        [_captureSession addInput:_captureVideoInput];
    }
    [self.captureSession commitConfiguration];
}
@end
