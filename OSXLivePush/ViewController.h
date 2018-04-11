//
//  ViewController.h
//  OSXLivePush
//
//  Created by zhao on 16/7/22.
//  Copyright © 2016年 zhao. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

@interface ViewController : NSViewController

@property (weak) IBOutlet NSButton *buttonClick;
- (IBAction)buttonAction:(NSButton *)sender;
@property (weak) IBOutlet NSView *customView;

@property (weak) IBOutlet NSButton *typeButton;
- (IBAction)typeClick:(NSButton *)sender;

@property (nonatomic,strong)  AVCaptureSession *captureSession;//负责输入和输出设备之间
@property (strong ,nonatomic) AVCaptureInput *captureVideoInput;//负责从视频获得输入数据
@property (strong,nonatomic)  AVCaptureVideoDataOutput *captureVideoOutput;//照片输出流
@property (strong,nonatomic)  AVCaptureAudioDataOutput *captureAudioOutput;//音频输出流
@property (strong,nonatomic) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer;//相机拍摄预览图层

@end

