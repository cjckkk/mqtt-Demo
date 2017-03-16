//
//  ViewController.m
//  Mqtt-demo
//
//  Created by jason on 2017/3/16.
//  Copyright © 2017年 jason. All rights reserved.
//

#import "ViewController.h"
//#import<MQTTClient/MQTTClient>
#import <MQTTClient/MQTTClient.h>
@interface ViewController ()<MQTTSessionDelegate>

@property (strong,nonatomic) MQTTSession *session;
@property (strong,nonatomic) NSMutableDictionary *dataDict;
@property (strong,nonatomic) NSTimer *timer;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

   
    //1.地址 端口
    NSString *serverHost = @"";
    NSString *userName = @"";
    NSString *userPwd = @"";

    UInt16 serverPort = 1883;//默认
    MQTTCFSocketTransport *transport =     [[MQTTCFSocketTransport alloc] init];
    transport.host = serverHost;
    transport.port =serverPort;
    
    
    //2.设置mqtt的账号和密码，同样找好基友要
    self.session = [[MQTTSession alloc] init];
    self.session.transport = transport;
    self.session.delegate = self;
    
    
    
    self.session.userName = userName;
    self.session.password = userPwd;
    
    //超时时间 越小越好
    [self.session connectAndWaitTimeout:1];
    
    
    //3. 最后订阅主题，这个地方看了很多人写的博客，假设你的主题很多比如5个,10个，使用线程处理，这样也是可以的，但是不是最优化的方式，后面会详细说明，对了mqtt是可以同时订阅多个主题的，很多资料都未说明.
    // 这个地方用了枚举，主要是为了判断订阅主题，来处理回调的数据
    
    //注意:订阅主题不能放到子线程进行,否则block不会回调
    //主题格式          @“$IOT/haha/datapoint/motor_control”
    
    
    //4.实时检测网络
    self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(monitorStatus) userInfo:nil repeats:true];
    
}
///** QoS(Quality of Service,服务质量) */
//typedef NS_ENUM(UInt8, RHMQTTQosLevel) {
//    RHMQTTQosLevelAtMostOnce = 0,               //至多一次，发完即丢弃，<=1
//    RHMQTTQosLevelAtLeastOnce = 1,              //至少一次，需要确认回复，>=1
//    RHMQTTQosLevelExactlyOnce = 2,              //只有一次，需要确认回复，＝1
//    RHMQTTQosLevelReserved = 3                  //待用，保留位置
//};
//“至多一次”，消息发布完全依赖底层 TCP/IP 网络。会发生消息丢失或重复。这一级别可用于如下情况，环境传感器数据，丢失一次读记录无所谓，因为不久后还会有第二次发送。
//“至少一次”，确保消息到达，但消息重复可能会发生。
//“只有一次”，确保消息到达一次。这一级别可用于如下情况，在计费系统中，消息重复或丢失会导致不正确的结果。
+(void)subscibeTopic:(MQTTSession *)session ToTopic:(NSString *)topicUrl
{
    [session subscribeToTopic:topicUrl atLevel:MQTTQosLevelAtMostOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        
        if (error) {
            NSLog(@"订阅 %@ 失败 原因 %@",topicUrl,error);
        }else
        {
            NSLog(@"订阅 %@ 成功 g1oss %@",topicUrl,gQoss);

        };
    }];

}

//第四步：实现Session代理方法，处理数据
#pragma mark  -------------------------------------------------------   获取到mqtt的数据  -------------------------------------------------
-(void)newMessage:(MQTTSession *)session data:(NSData *)data onTopic:(NSString *)topic qos:(MQTTQosLevel)qos retained:(BOOL)retained mid:(unsigned int)mid
{

    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    [self.dataDict setDictionary:dict];
    
    if (dict.count) {
        
        //判断属于哪个主题的
        
        
        
        
        
    }
    //1.如果你订阅的主题只有一个，那么你不判断也是可以的，但是如果有多个主题，你需要判断，返回的哪个对应的主题，然后才能处理数据。
    
   // 2.你订阅主题假如是这样的    @“$IOT/haha/datapoint/motor_control”  ，那么在处理数据时，你判断“motor_control”字符串就可以找到对应的数据,判断最后的参数就行，看截图就明白了.
    
   // 3.然后拿到你的数据，你想干嘛就干嘛.
}
#pragma mark  -------------------------------------------------------   网络连接状态  -------------------------------------------------
-(void)monitorStatus
{
    if (self.session.status ==4) {
        [self.session connect];
    }

}

@end
