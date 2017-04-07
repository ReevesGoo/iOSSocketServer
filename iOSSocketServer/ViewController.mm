//
//  ViewController.m
//  iOSSocketServer
//
//  Created by ReevesGoo on 2017/3/15.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

#import "ViewController.h"
#import "MyServer.h"
#include <OpenAL/OpenAL.h>
#import <AVFoundation/AVFoundation.h>
#import "Record.h"
#import "Play.h"

//#import "VoiceConvertHandle.h"
@interface ViewController ()<MyServerDelegete, RecordDelegate>

@property (nonatomic, strong) Record *recorder;
@property (strong, nonatomic) Play *play;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (strong, nonatomic) MyServer *myServer;

@end

@implementation ViewController

- (void)showtitle:(NSString *)title {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = title;
    });
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.myServer = [MyServer new];
    self.myServer.delegate = self;
    self.recorder = [[Record alloc] init];
    self.recorder.delegate = self;
    _play = [[Play alloc] init];
    
}

-(void)covertedData:(NSData *)data{
//    [self.myServer sendData:data];
}


- (void)record:(Record *)record AudioBuffer:(NSData *)buffer withQueue:(AudioQueueRef)queue {
    
    [self.myServer sendData:buffer];
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.textView resignFirstResponder];
}
- (IBAction)record:(UIButton *)sender {
   
    
    if ([sender.currentTitle isEqualToString:@"录音"]) {
        [self.recorder start];
//        [VoiceConvertHandle shareInstance].startRecord = YES;
        [sender setTitle:@"停止" forState:UIControlStateNormal];
    }else{
        [self.recorder stop];
//        [VoiceConvertHandle shareInstance].startRecord = NO;
        [sender setTitle:@"录音" forState:UIControlStateNormal];
    }

}
- (IBAction)play:(UIButton *)sender {
    [self.play Play:self.recorder.getBytes Length:9999999];
}

- (IBAction)startServer:(UIButton *)sender {
    [self.myServer startListenAndNewThread];
}

- (IBAction)stopServer:(UIButton *)sender {
    [self.myServer closeServer];
}
- (IBAction)sendMsg:(UIButton *)sender {
//    [self.myServer sendData:[self.textView.text UTF8String]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
