//
//  MyServer.h
//  iOSSocketServer
//
//  Created by ReevesGoo on 2017/3/15.
//  Copyright © 2017年 ReevesGoo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol MyServerDelegete <NSObject>

- (void)showtitle:(NSString *)title;

@end

@interface MyServer : NSObject{
    BOOL isClosed;
    int toServerSocket;

}
// 初始化服务器
-(void) initServer;
// 读客户端数据
//-(void) readData:(NSNumber*) clientSocket;
// 向客户端发送数据
-(void) sendData:(NSData *)data;
// 在新线程中监听客户端
-(void) startListenAndNewThread;
-(void) closeServer;

@property (nonatomic,strong) NSMutableArray *socketArray;

@property (nonatomic, weak) id <MyServerDelegete> delegate;

@end



