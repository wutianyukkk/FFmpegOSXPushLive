//
//  QTFFAVStreamer.h
//  QTFFmpeg
//
//  Created by Brad O'Hearne on 3/14/13.
//  Copyright (c) 2013 Big Hill Software LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QTKit/QTKit.h>
#import <AVFoundation/AVFoundation.h>


@interface QTFFAVStreamer : NSObject

@property (nonatomic, readonly) BOOL isStreaming;

#pragma mark - Stream opening and closing

- (BOOL)openStream:(NSError **)error;

- (BOOL)closeStream:(NSError **)error;

#pragma mark - Frame streaming

- (BOOL)streamVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (BOOL)streamAudioFrame:(CMSampleBufferRef)sampleBuffer;

@end
