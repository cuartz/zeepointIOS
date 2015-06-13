//
//  ZipOintService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//
#import "ZiPointWSService.h"
#import "MMPReactiveStompClient.h"
#import <SocketRocket/SRWebSocket.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Constants.h"

@interface ZiPointWSService () //<SRWebSocketDelegate>

@property (nonatomic, strong) MMPReactiveStompClient *client;

@property (nonatomic, strong) NSString *channel;

@property (nonatomic, strong) NSMutableURLRequest *request;

-(void)subscribeZip:(NSString *) newChannel;
//SEL subscribeSel = @selector(subscribe:);
//-(void)subscribe2:(NSString *) newChannel;

@end

@implementation ZiPointWSService

@synthesize channel;

@synthesize request;

@synthesize delegate;

@synthesize client;

@synthesize lat;

@synthesize lon;

@synthesize zeePoint;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static ZiPointWSService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:WS,IP]]];
        NSDictionary *headers = @{
                                  @"content-type": @"application/json;charset=utf-8",
                                  @"origin": WS_ENVIROMENT
                                  };
        [request setAllHTTPHeaderFields:headers];
        //client = [[MMPReactiveStompClient alloc] initWithURLRequest:request];
        client = [[MMPReactiveStompClient alloc] initWithOutSocket];


    }
    return self;
}

-(void)subscribeZip:(NSString *) newChannel{
    channel=newChannel;
    
    [[client open:request]
     subscribeNext:^(id x) {
         if ([x class] == [SRWebSocket class]) {
             // First time connected to WebSocket, receiving SRWebSocket object
             [[client stompMessagesFromDestination:[NSString stringWithFormat:@"/topic/channels/%@",channel]] 
              subscribeNext:^(MMPStompMessage *message) {
                  //NSLog(@"STOMP message received: body = %@", message.body);
                  NSString *jsonString=[message body];
                  NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                  //id *json = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
                  NSDictionary *messageData=[NSJSONSerialization JSONObjectWithData:data
                                                                            options:0
                                                                              error:NULL];
                  //NSString *receivedMessage= [messageData objectForKey:@"message"];
                   [delegate receiveMessage:messageData  putMessageAtFirst:(BOOL *)false];
                  
              }];
             
             NSLog(@"web socket connected with: %@", x);
         } else if ([x isKindOfClass:[NSString class]]) {
             
             /*
              
              */
             NSLog(@"web socket connected withghhhhh: %@", x);
             // Subsequent signals should be NSString
         }
     }
     error:^(NSError *error) {
         NSLog(@"web socket failed: %@", error);
         [self reConnect];
     }
     completed:^{
         [self reConnect];
        // NSLog(@"web socket closed");
     }];
    
}


-(void)reConnect{
    [delegate connecting];
    //[self subscribe:channel];
    [self performSelector:@selector(subscribeZip:) withObject:channel afterDelay:1];
}

- (void)sendMessage:(NSString *)body{
    [client sendMessage:body toDestination:STOMP_DESTINATION];
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end



/*
 @synthesize str;
 @synthesize  zipUsers;
 @synthesize  ziPoints;
 @synthesize ziPointJoined;
 @synthesize avatars;
 
 static ZipOintService *instance = nil;
 
 +(ZipOintService *)getInstance
 {
 @synchronized(self)
 {
 if(instance==nil)
 {
 instance= [ZipOintService new];
 }
 }
 return instance;
 }
 
 +(NSString) getUserName{
 NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
 NSString *userId=[prefs objectForKey:@"userId"];
 NSString *fbUserId=[prefs objectForKey:@"fbUserId"];
 NSString *email=[prefs objectForKey:@"email"];
 }
 @end
 */