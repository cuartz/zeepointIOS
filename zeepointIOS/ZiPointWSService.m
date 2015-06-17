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
#import "LoadingView.h"

@interface ZiPointWSService ()

@property (nonatomic, strong) MMPReactiveStompClient *client;

@property (nonatomic, strong) NSString *channel;

@property BOOL connected;

@property (nonatomic, strong) NSMutableURLRequest *request;

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fbUserId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) UIView *loadingView;


-(void)subscribeZip:(NSString *) newChannel;

@end

@implementation ZiPointWSService

@synthesize channel;

@synthesize request;

@synthesize delegate;

@synthesize client;

@synthesize lat;

@synthesize lon;

@synthesize loadingView;

@synthesize zeePoint;

@synthesize zeePointUsers;

@synthesize  avatars;

@synthesize  images;

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
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _userId=[prefs objectForKey:@"userId"];
        _fbUserId=[prefs objectForKey:@"fbUserId"];
        _email=[prefs objectForKey:@"email"];
        _deviceToken=[prefs objectForKey:@"DeviceToken"];
        _userName=[prefs objectForKey:@"name"];
        loadingView = [[LoadingView alloc] init];
        
        client = [[MMPReactiveStompClient alloc] initWithOutSocket];
        
        zeePointUsers=[[NSMutableSet alloc] init];
        avatars=[[NSMutableDictionary alloc] init];
        images=[[NSMutableDictionary alloc] init];
        
        [self connect];


    }
    return self;
}

-(void)connect {
   // channel=newChannel;
    
    [[client open:request]
     subscribeNext:^(id x) {
         if ([x class] == [SRWebSocket class]) {
             self.connected=TRUE;
             
             if (channel){
                [self subscribeZip:channel];
             }
             // First time connected to WebSocket, receiving SRWebSocket object

             [delegate didJustConnect];
             NSLog(@"web socket connected");
         } else if ([x isKindOfClass:[NSString class]]) {
             
             NSLog(@"web socket connected withghhhhh");
             // Subsequent signals should be NSString
         }
     }
     error:^(NSError *error) {
         NSLog(@"web socket failed");
         [self reConnect];
     }
     completed:^{
         NSLog(@"web socket failed");
         [self reConnect];
     }];
    
}

-(void)subscribeZip:(NSString *) newChannel{
    channel=newChannel;
    if (self.connected){
    [[client stompMessagesFromDestination:[NSString stringWithFormat:@"/topic/channels/%@",channel]]
     subscribeNext:^(MMPStompMessage *message) {
         NSString *jsonString=[message body];
         NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
         NSDictionary *messageData=[NSJSONSerialization JSONObjectWithData:data
                                                                   options:0
                                                                     error:NULL];
         [delegate receiveWSMessage:[self createZipointMessage:messageData]];
         
     }];
    }
}

-(void)unSubscribeZip{
    if (self.connected){
        [client unSubscribe];
    }
}


-(void)reConnect{
    self.connected=FALSE;
    [delegate connecting:loadingView];
    //[self subscribe:channel];
    [self performSelector:@selector(subscribeZip:) withObject:channel afterDelay:2];
}

- (void)sendMessage:(NSString *)body{
    [client sendMessage:body toDestination:STOMP_DESTINATION];
}


- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

-(void)setDeviceToken:(NSString *) deviceToken{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:deviceToken forKey:@"DeviceToken"];
    _deviceToken=deviceToken;
}

-(NSString *) getDeviceToken{
    return _deviceToken;
}

-(void)setUserId:(NSString *) userId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:userId forKey:@"userId"];
    _userId=userId;
}

-(NSString *) getUserId{
    return _userId;
}

-(void)setFbUserId:(NSString *)fbUserId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:fbUserId forKey:@"fbUserId"];
    _fbUserId=fbUserId;
}

-(NSString *) getFbUserId{
    return _fbUserId;
}

-(void)setEmail:(NSString *)email{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:email forKey:@"email"];
    _email=email;
}

-(NSString *) getEmail{
    return _email;
}

-(void)setUserName:(NSString *)name{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:name forKey:@"name"];
    _userName=name;
}

-(NSString *) getUserName{
    return _userName;
}

-(ZeePointGroup *)createZipointGroup:(NSDictionary *)dict{
    ZeePointGroup *item = [[ZeePointGroup alloc] init];
    item.zpointId=[dict objectForKey:@"id"];
    item.name = [dict objectForKey:@"name"];
    item.users = [dict objectForKey:@"users"];
    //item.range = [zpoint objectForKey:@"name"];
    item.distance = [dict objectForKey:@"distance"];
    //item.friends = [zpoint objectForKey:@"name"];
    item.listeners = [dict objectForKey:@"listeners"];
    item.referenceId = [dict objectForKey:@"referenceId"];
    
    item.joined=[[dict objectForKey:@"joined"] boolValue];
    
    return item;
}

-(NSMutableSet *)createZipointGroups:(NSDictionary *)dict{
    NSArray *zpointsDict=[dict objectForKey:@"zeePointsOut"];
    NSMutableSet *zpointsArray=[[NSMutableSet alloc] init];
    
    for (NSDictionary *zpoint in zpointsDict) {
        [zpointsArray addObject:[self createZipointGroup:zpoint]];
    }
    return zpointsArray;
}

-(ZiPointMessage *)createZipointMessage:(NSDictionary *)dict{
    ZiPointMessage *item = [[ZiPointMessage alloc] init];
    
    item.message=[dict objectForKey:@"message"];
    item.tempId=[dict objectForKey:@"id"];
    item.userId=[[dict objectForKey:@"userId"] description];
    item.messageId=[dict objectForKey:@"messageId"];
    item.userName=[dict objectForKey:@"userName"];
    item.fbId=[dict objectForKey:@"fbId"];
    item.messageType=[dict objectForKey:@"messageType"];
    item.time=[dict objectForKey:@"time"];
    
    return item;
}

-(NSMutableArray *)createZipointMessages:(NSDictionary *)dict{
    NSMutableArray *messages=[[NSMutableArray alloc] init];
    NSArray *messagesDict=[dict objectForKey:@"zMessages"];
    
    for (NSDictionary *message in messagesDict) {
        [messages addObject:[self createZipointMessage:message]];
    }
    return messages;
}

-(NSMutableSet *)createZipointUsers:(NSDictionary *)dict{
    NSArray *zpointUsersDict=[dict objectForKey:@"users"];
    NSMutableSet *zpointUsersArray=[[NSMutableSet alloc] init];
    
    
    for (NSDictionary *zpointUser in zpointUsersDict) {
        [zpointUsersArray addObject:[self createZipointUser:zpointUser]];
    }
    return zpointUsersArray;
    
}

-(ZeePointUser *)createZipointUser:(NSDictionary *)dict{
    
    ZeePointUser *item = [[ZeePointUser alloc] init];
    
    item.fbId=[dict objectForKey:@"fbId"];
    item.gender = [dict objectForKey:@"gender"];
    item.userId = [dict objectForKey:@"id"];
    //item.range = [zpoint objectForKey:@"name"];
    item.age = [dict objectForKey:@"age"];
    //item.friends = [zpoint objectForKey:@"name"];
    //item.email = [zpointUser objectForKey:@"listeners"];
    item.userName = [dict objectForKey:@"name"];
    //item8.hiddenn=@YES;
    return item;
}

-(NSData *)loadImageAsync:(NSURL *)imageURL imageKey:(NSString *)key isImageForAmessage:(bool) isMessage secondImageKey:(NSString *)secKey{
    __block NSData *imageData;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized(images){
        if (![images objectForKey:key]){
                imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData){
                        [images setObject:imageData forKey:key];
                        if (secKey){
                            [images setObject:imageData forKey:secKey];
                            [delegate imageLoaded:imageData messageKey:secKey isImageForMessage:isMessage];
                        }
                        [delegate imageLoaded:imageData messageKey:key isImageForMessage:isMessage];
                    }
                });
            }
        }
    });
    return imageData;
}

@end