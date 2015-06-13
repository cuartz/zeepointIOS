//
//  ZipOintService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZipOintService.h"
#import <WebsocketStompKit/WebsocketStompKit.h>
#import "Constants.h"

@interface ZipOintService () <STOMPClientDelegate>

@property (nonatomic, strong) STOMPClient *client;

@property (nonatomic, strong) NSString *channel;



@end

@implementation ZipOintService

@synthesize channel;

@synthesize delegate;

@synthesize client;
static dispatch_once_t onceToken=0;
#pragma mark Singleton Methods

+ (id)sharedManager {
    static ZipOintService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        

        
        
        [self connect];
    }
    return self;
}


- (void)connect
{
    NSDictionary *HEADERS = @{@"content-type": @"application/json;charset=utf-8",@"origin": WS_ENVIROMENT};
    NSURL *websocketUrl = [NSURL URLWithString:WS];
    //[client disconnect];
    //dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
    self.client=nil;
    client.delegate=self;
    dispatch_once(&onceToken, ^{
        
        //if(![client connected]){
            client = [[STOMPClient alloc] initWithURL:websocketUrl webSocketHeaders:HEADERS useHeartbeat:NO];
            [self.client connectWithLogin:@"''" passcode:@"''"
                        completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
                            if (error) {
                                [delegate connecting];
                                //[NSThread sleepForTimeInterval:3.0f];
                                //[self performSelector:@selector(connect) withObject:nil afterDelay:1];
                            } else {
                                [delegate didJustConnect];
                            }
                        }];
        //}
        });

        //Do EXTREME PROCESSING!!!
       /* for (int i = 0; i< 100; i++) {
            [NSThread sleepForTimeInterval:.05];
            NSLog(@"%i", i);
        }*/
        
   // });

/*
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                NSLog(@"Connecting...");
                //@synchronized(self.client){
                    if(![client connected]){
                        [self.client connectWithLogin:@"''" passcode:@"''"
                                    completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
                                        if (error) {
                                            [delegate connecting];
                                            [NSThread sleepForTimeInterval:3.0f];
                                            [self connect];
                                        } else {
                                            [delegate didJustConnect];
                                        }
                                    }];
                    }
                //}
            }
            @catch (NSException *exception) {
                [delegate connecting];
                [NSThread sleepForTimeInterval:3.0f];
                [self connect];
            }
        });
    });*/

    // when the method returns, we can not assume that the client is connected
}

-(void)subscribe:(NSString *) newChannel{
    channel=newChannel;
    [self.client subscribeTo:[NSString stringWithFormat:@"/topic/channels/%@",channel] messageHandler:^(STOMPMessage *message) {
        NSString *jsonString=[message body];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *messageData=[NSJSONSerialization JSONObjectWithData:data
                                                                  options:0
                                                                    error:NULL];
        [delegate receiveMessage:messageData  putMessageAtFirst:(BOOL *)false];

    }];
}

- (void)sendMessage:(NSString *)body{
    [client sendTo:STOMP_DESTINATION
     //headers:headers
                   body:body];
}

//- (void)receiveMessage:(NSDictionary *)message{
    


- (void) websocketDidDisconnect: (NSError *)error{
    //
    onceToken=onceToken+1;
    NSLog(@"CONNECTING");
    [delegate connecting];
    [self performSelector:@selector(connect) withObject:nil afterDelay:1];
    //[self connect];
    
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