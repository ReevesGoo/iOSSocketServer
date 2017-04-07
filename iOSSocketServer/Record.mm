//
//  Record.m
//  iOSSocketServer
//
//  Created by ReevesGoo on 2017/3/15.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

#import "Record.h"

@implementation Record
@synthesize aqc;
@synthesize audioDataLength;

static void AQInputCallback(
                            void * __nullable               inUserData,
                            AudioQueueRef                   inAQ,
                            AudioQueueBufferRef             inBuffer,
                            const AudioTimeStamp *          inStartTime,
                            UInt32                          inNumberPacketDescriptions,
                            const AudioStreamPacketDescription * __nullable inPacketDescs)
{
    
    Record * engine = (__bridge Record *) inUserData;
    if (inStartTime > 0)
    {
        [engine processAudioBuffer:inBuffer withQueue:inAQ];
    }
    
    if (engine.aqc.run)
    {
        AudioQueueEnqueueBuffer(engine.aqc.queue, inBuffer, 0, NULL);
    }
}

- (id) init
{
    self = [super init];
    if (self)
    {
        aqc.mDataFormat.mSampleRate = kSamplingRate;
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
        aqc.mDataFormat.mBytesPerPacket = kBytesPerFrame;
        aqc.mDataFormat.mBytesPerFrame = kBytesPerFrame;   // (kNumberChannels * sizeof(SInt16))
                                                   //*mAudioFormat.mChannelsPerFrame * (sizeof(SInt16) * 8)/8;

        aqc.frameSize = kFrameSize;
        
        AudioQueueNewInput(&aqc.mDataFormat, AQInputCallback, (__bridge void *)(self), NULL, kCFRunLoopCommonModes,0, &aqc.queue);
        
        for (int i=0;i<kNumberBuffers;i++)
        {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.recPtr = 0;
        aqc.run = 1;
        self.tempData = [NSMutableData data];
    }
    audioDataIndex = 0;
    return self;
}

- (void) dealloc
{
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void) start
{
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop
{
    AudioQueueStop(aqc.queue, true);
}

- (void) pause
{
    AudioQueuePause(aqc.queue);
}

- (Byte *)getBytes
{
    return audioByte;
}

- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue
{
    
//    NSLog(@"processAudioData :%u", (unsigned int)buffer->mAudioDataByteSize);
    memcpy(audioByte+audioDataIndex, buffer->mAudioData, buffer->mAudioDataByteSize);
    audioDataIndex +=buffer->mAudioDataByteSize;
    audioDataLength = audioDataIndex;
    
    NSData *data = [NSData dataWithBytes:buffer->mAudioData length:buffer->mAudioDataByteSize];
    [self.tempData appendData:data];
    if (self.tempData.length >= 1000) {
        NSData *sendData = [self.tempData subdataWithRange:NSMakeRange(0, 1000)];
        if (self.delegate && [self.delegate respondsToSelector:@selector(record:AudioBuffer:withQueue:)]) {
            NSLog(@"%ld",sendData.length);
            [self.delegate record:self AudioBuffer:sendData withQueue:queue];
        }
        self.tempData = [self.tempData subdataWithRange:NSMakeRange(1000, self.tempData.length - 1000)].mutableCopy;
    }

}

@end
