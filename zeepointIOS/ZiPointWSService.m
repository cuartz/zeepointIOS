//
//  ZipOintService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//
#import "ZiPointWSService.h"
#import "ZiPointDataService.h"
#import "MMPReactiveStompClient.h"
#import "SRWebSocket.h"
#import "ReactiveCocoa.h"
#import "Constants.h"
#import "LoadingView.h"
#import "LoadImageService.h"
#import "CoreDataService.h"

@interface ZiPointWSService ()<LoadImageServiceDelegatessage>

@property (nonatomic, strong) MMPReactiveStompClient *client;

//@property (nonatomic, strong) NSString *channel;



@property int oldestMessage;

@property (nonatomic, strong) ZeePointGroup *zeePoint;

@property (nonatomic, strong) ZeePointUser *zeePointUser;

@property (nonatomic, strong) ZiPointDataService *dataService;

@property (nonatomic, strong) LoadImageService *imageService;

@property (nonatomic, strong) CoreDataService *coreDataService;

//-(void)subscribeZip;

@end

@implementation ZiPointWSService

@synthesize delegate;

@synthesize client;
//@synthesize channel;
/*


@synthesize lat;

@synthesize lon;

@synthesize loadingView;

//@synthesize zeePoint;

@synthesize zeePointUsers;

@synthesize locationZiPoints;

@synthesize myZiPoints;

@synthesize  avatars;

@synthesize  images;
*/
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
        

        //client =[[MMPReactiveStompClient alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:WS,IP]]];

        //client = [[MMPReactiveStompClient alloc] initWithURLRequest:request];//initWithOutSocket];
        
        [self connect];
        
        self.dataService=[ZiPointDataService sharedManager];
        self.coreDataService=[CoreDataService sharedManager];
        self.imageService=[[LoadImageService alloc] init];
        self.imageService.delegate=self;

    }
    return self;
}

-(void)connect {
   // channel=newChannel;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:WS,IP]]];
    NSDictionary *headers = @{
                              @"content-type": @"application/json;charset=utf-8",
                              @"origin": WS_ENVIROMENT
                              };
    [request setAllHTTPHeaderFields:headers];
    
    client = [[MMPReactiveStompClient alloc] initWithURLRequest:request];//initWithOutSocket];
    
    [[client open]
     subscribeNext:^(id x) {
         if ([x class] == [SRWebSocket class]) {
             self.connected=TRUE;
             
             //[self joinZiPoint];
             //if (self.zeePoint){
                [self subscribeZip];
             //}
             // First time connected to WebSocket, receiving SRWebSocket object

             
             NSLog(@"web socket connected");
         } else if ([x isKindOfClass:[NSString class]]) {
             
             NSLog(@"web socket connected withghhhhh");
             // Subsequent signals should be NSString
         }
     }
     error:^(NSError *error) {
         NSLog(@"web socket failed error");
         [self reConnect];
     }
     completed:^{
         NSLog(@"web socket failed completed");
         [self reConnect];
     }];
    
}

-(BOOL)isConnected{
    return self.connected;
}

-(void)uploadImage:(NSData *)dataImage randomNumber:(NSNumber *)randomPublicId{
    [_imageService uploadImage:dataImage randomNumber:randomPublicId];
}

-(void)finishLoadingImage{
    
}

-(void)finishUploadingImage:(NSString *)urlMessage messageId:(NSNumber *)myMsgid messageType:(NSString *)PHOTO_MESSAGE{
    [self sendMessage:urlMessage messageId:myMsgid messageType:PHOTO_MESSAGE];
}


-(void)setZiPoint:(ZeePointGroup *)ziPoint{
    if (ziPoint && ![ziPoint isEqual:self.zeePoint]){
        self.zeePoint=ziPoint;
        if (self.zeePoint){
            [self subscribeZip];
        }
    }else{
/*        if (!ziPoint){
            [self unSubscribeZip];
        }*/
        self.zeePoint=ziPoint;
    }
}

-(ZeePointGroup *) getZiPoint{
    return self.zeePoint;
}

-(void)subscribeZip{
    
    //[self unSubscribeZip];
    //@synchronized(self.connected) {
    if (!self.connected){
        [self connect];
    }else{
        if (self.zeePoint){
            [self joinZiPoint];

        
        }
    }
    //}
}
/*
-(void) channelConnected{
    
}

-(void)unSubscribeZip{
    self.oldestMessage=0;
    
    //[delegate finishReceivingMessageAnimatedNoScroll];
    if (self.connected){
        [client unSubscribe];
    }
}*/


-(void)reConnect{
    self.connected=FALSE;
    [delegate connecting];
    //[self subscribe:channel];
    [self performSelector:@selector(subscribeZip) withObject:nil afterDelay:2];
}


- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
        messageType:(NSString *)messageType{
    // build a static NSDateFormatter to display the current date in ISO-8601
    /*static NSDateFormatter *dateFormatter = nil;
     static dispatch_once_t onceToken;
     dispatch_once(&onceToken, ^{
     dateFormatter = [[NSDateFormatter alloc] init];
     dateFormatter.dateFormat = @"yyyy-MM-d'T'HH:mm:ssZZZZZ";
     });*/
    
    // send the message to the truck's topic
    // build a dictionary containing all the information to send
    
    
    
    //IMPORTANTE, CHECAR SI SE PUEDE QUITAR
    //NSURL *imageURL = [NSURL URLWithString:[urlMessage stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    //[imageService loadImageAsync:imageURL imageKey:urlMessage isImageForAmessage:true secondImageKey:fileName];
    
    NSDictionary *dict = @{
                           @"message": message,
                           @"id": myMsgId,
                           @"channel":self.zeePoint.referenceId,
                           @"userId":[_dataService getUserId],
                           @"fbId":[_dataService getFbUserId],
                           @"userName":[_dataService getUserName],
                           @"messageType":messageType
                           };
    // create a JSON string from this dictionary
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *body =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self sendMessage:body];
    
}

- (void)sendMessage:(NSString *)body{
    [client sendMessage:body toDestination:[NSString stringWithFormat:STOMP_DESTINATION,self.zeePoint.referenceId]];
}



- (void)getPreviousMessages{
NSString *zpointFinalURL=[NSString stringWithFormat:GET_PREVIOUS_MSGS,WS_ENVIROMENT,self.zeePoint.zpointId,[_dataService getUserId],self.oldestMessage];
NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
NSURLRequest *serviceRequest = [NSURLRequest requestWithURL:url];
[NSURLConnection sendAsynchronousRequest:serviceRequest
                                   queue:[NSOperationQueue mainQueue]
                       completionHandler:^(NSURLResponse *response,
                                           NSData *data, NSError *connectionError)
 {
     if (data.length > 0 && connectionError == nil)
     {
         
         NSDictionary *ziPointJoinInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:NULL];
         NSArray *previousMessages=[self createZipointMessages:ziPointJoinInfo];
         
         //NSArray *messages=[ziPointJoinInfo objectForKey:@"zMessages"];
         
         for (ZiPointMessage *message in previousMessages) {
             [self receiveMessage:message putMessageAtFirst:true];
             
         }
         [delegate finishReceivingMessageAnimatedNoScroll];
     }
 }];
}

- (void)receiveWSMessage:(ZiPointMessage *)message
{
    [self receiveMessage:message putMessageAtFirst:false];
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [delegate finishReceivingMessageAnimated:YES];
}

- (void)receiveMessage:(ZiPointMessage *)message putMessageAtFirst:(bool)atFirst{
    if ([self.zeePoint.referenceId isEqualToString:message.channel]){
    if ([[_dataService getUserId] isEqualToString:message.userId]  && (message.messageId==nil || message.messageId==(id)[NSNull null])){
        // YOUR MESSAGE HAS BEEN RECEIVED
        
        if ([_dataService.messages count] > [(message.tempId) intValue] &&
            [[[_dataService.messages objectAtIndex:[((NSNumber *)message.tempId) intValue]] text] isEqualToString:message.message] &&
            [[_dataService.messages objectAtIndex:[((NSNumber *)message.tempId) intValue]] received]==false){
            [[_dataService.messages objectAtIndex:[((NSNumber *)message.tempId) intValue]] setReceived:true];
            
        }else{
            for (JSQMessage *msg in _dataService.messages){
                if ([msg isMediaMessage] && ![msg received]){
                    
                } else if ([[msg text] isEqualToString:message.message] && ![msg received]){
                    [msg setReceived:true];
                    break;
                }
            }
        }
        
    }else{
        //other user message or own message that was sent before
        if (message.messageId!=nil && message.messageId!=(id)[NSNull null] && (self.oldestMessage==0 || self.oldestMessage>[message.messageId intValue])){
            self.oldestMessage=[message.messageId intValue];
        }
        [self.imageService loadUserImage:message.userId faceBookId:message.fbId];
        /*if ([self.images objectForKey:[message.userId description]]==nil){
            NSString *picFinalURL=[NSString stringWithFormat:FB_USER_PIC,message.fbId];
            NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
            [self loadImageAsync:imageURL imageKey:[message.userId description] isImageForAmessage:false secondImageKey:nil];
            
        }*/
        
        JSQMessage *newMessage;
        if ([[message.messageType description] isEqualToString:PHOTO_MESSAGE]){
            JSQPhotoMediaItem *photoItem;
            //if ([zipService.images objectForKey:message.message]==nil){
            if ([message.userId isEqual:_dataService.getUserId]){
                photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
            }else{
                photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:NO];
            }
            newMessage=  [[JSQMessage alloc] initWithSenderId:message.userId
                                            senderDisplayName:message.userName
                                                         date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)message.time longValue] /1000.0]
                                                        media:photoItem];
            newMessage.text=message.message;
            if (atFirst){
                [_dataService.messages insertObject:newMessage atIndex:0];
            }else{
                [_dataService.messages addObject:newMessage];
            }
            [self.imageService imageMessageReceived:message];
            
        }else{
            newMessage=  [[JSQMessage alloc] initWithSenderId:message.userId
                                            senderDisplayName:message.userName
                                                         date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)message.time longValue] /1000.0]
                                                         text:message.message];
            newMessage.received=true;
            if (atFirst){
                [_dataService.messages insertObject:newMessage atIndex:0];
            }else{
                [_dataService.messages addObject:newMessage];
            }
        }
    }
    }
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
    item.ownerId = [dict objectForKey:@"ownerId"];
    item.latitud = [dict objectForKey:@"latitud"];
    item.longitud = [dict objectForKey:@"longitud"];
    
    item.joined=[[dict objectForKey:@"joined"] boolValue];
    if (item.joined){
        if (![self getZiPoint]){
            [self setZiPoint:item];
        }else if (![item isEqual:[self getZiPoint]]){
            item.joined=false;
        }
    }
    if ([_dataService.getUserId isEqualToString:item.ownerId]){
    if ([_dataService.myZiPoints member:item]){
        //   updatedZip.distance=currentZip.distance;
        [_dataService.myZiPoints removeObject:item];
    }
    //else{
    [_dataService.myZiPoints addObject:item];
    }
//}


    //if (item.distance<=100){

    //}
        
    
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
    item.channel=[dict objectForKey:@"channel"];
    



    
    return item;
}

-(NSMutableArray *)createZipointMessages:(NSDictionary *)dict{
    NSMutableArray *messagesArray=[[NSMutableArray alloc] init];
    NSArray *messagesDict=[dict objectForKey:@"zMessages"];
    
    for (NSDictionary *message in messagesDict) {
        [messagesArray addObject:[self createZipointMessage:message]];
    }
    return messagesArray;
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
    
    if (self.getZiPoint && [self.getZiPoint.ownerId isEqualToString:[item.userId description]]){
        item.title=@"Owner";
    }else{
        item.title=@"User";
    }
    [_coreDataService createZiPUser:item];
    
    [self.imageService loadUserImage:item.userId faceBookId:item.fbId];

    
    return item;
}

- (void)saveUserInfo:(NSString *) fbUserId :(NSString *)deviceToken{
    
    NSString *zpointFinalURL=[NSString stringWithFormat:LOGIN_USER_SERVICE,WS_ENVIROMENT,fbUserId, deviceToken];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *serviceRequest = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:serviceRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil &&
             [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"name"]!=nil)
         {
             NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             [_dataService setUserId:[[response objectForKey:@"id"] description]];
             //NSString *host=[greeting objectForKey:@"host"];
             [_dataService setFbUserId:fbUserId];
             
             //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             //UIViewController *uiViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainMenuView"];
             
             //[self presentViewController:uiViewController animated:YES completion:nil];
         }
         else{
             /* UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Code 002","Error code")
              message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
              delegate:nil
              cancelButtonTitle:@"OK"
              otherButtonTitles: nil];
              [alert show];*/
         }
     }];
}

- (void)joinZiPoint{
    [delegate connecting];
    //[self unSubscribeZip];
    //self.messages = [NSMutableArray new];
NSString *zpointFinalURL=[NSString stringWithFormat:JOIN_ZPOINT_SERVICE,WS_ENVIROMENT,self.zeePoint.zpointId,_dataService.getUserId,_dataService.lat,_dataService.lon];
NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
NSURLRequest *requestJoin = [NSURLRequest requestWithURL:url];
[NSURLConnection sendAsynchronousRequest:requestJoin
                                   queue:[NSOperationQueue mainQueue]
                       completionHandler:^(NSURLResponse *response,
                                           NSData *data, NSError *connectionError)
 {
     if (data.length > 0 && connectionError == nil)
     {
         [_dataService.messages removeAllObjects];//= [NSMutableArray new];
         NSDictionary *ziPointJoinInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                         options:0
                                                                           error:NULL];
         
         NSMutableArray *messagesArray=[self createZipointMessages:ziPointJoinInfo];//[ziPointJoinInfo objectForKey:@"zMessages"];
         
         for (ZiPointMessage *message in messagesArray) {
             
             [self receiveMessage:message putMessageAtFirst:false];
         }
         
         //[delegate finishReceivingMessageCustom:YES];
         
         //[self subscribeZip];
         
         _dataService.zeePointUsers=[self createZipointUsers:ziPointJoinInfo];
         
         [delegate didJustConnect];
         
         
         [[client stompMessagesFromDestination:[NSString stringWithFormat:@"/topic/channels/%@",self.zeePoint.referenceId]]
          subscribeNext:^(MMPStompMessage *message) {
              NSString *jsonString=[message body];
              NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
              NSDictionary *messageData=[NSJSONSerialization JSONObjectWithData:data
                                                                        options:0
                                                                          error:NULL];
              [self receiveWSMessage:[self createZipointMessage:messageData]];
              
          }];
         
         
         //[delegate didJustConnect];
     }
 }];

    
}

@end
