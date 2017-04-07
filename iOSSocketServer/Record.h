//
//  Record.h
//  iOSSocketServer
//
//  Created by ReevesGoo on 2017/3/15.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import "AudioConstant.h"

// use Audio Queue
@class Record;
@protocol RecordDelegate <NSObject>

- (void)record:(Record *)record AudioBuffer:(NSData *)buffer withQueue:(AudioQueueRef) queue;

@end

typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         mBuffers[kNumberBuffers];
    AudioFileID                 outputFile;
    
    unsigned long               frameSize;
    long long                   recPtr;
    int                         run;
    
} AQCallbackStruct;


@interface Record : NSObject
{
    AQCallbackStruct aqc;
    AudioFileTypeID fileFormat;
    long audioDataLength;
    Byte audioByte[999999999];
    long audioDataIndex;
}
- (id) init;
- (void) start;
- (void) stop;
- (void) pause;
- (Byte *) getBytes;
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue;

@property (nonatomic, assign) AQCallbackStruct aqc;
@property (nonatomic, assign) long audioDataLength;
@property (nonatomic, strong) NSMutableData *tempData;
@property (nonatomic, weak) id <RecordDelegate> delegate;
@end




