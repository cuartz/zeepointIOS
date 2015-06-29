//
//  ZipOintService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//
#import "PrivateWSService.h"
#import "ZiPointDataService.h"
#import "MMPReactiveStompClient.h"
#import <SocketRocket/SRWebSocket.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "Constants.h"
#import "LoadingView.h"

@interface PrivateWSService ()

@property (nonatomic, strong) MMPReactiveStompClient *client;
@property int oldestMessage;

@property (nonatomic, strong) NSMutableURLRequest *request;

@property (nonatomic, strong) ZeePointUser *zeePointUser;

@property (nonatomic, strong) ZiPointDataService *dataService;
@end

@implementation PrivateWSService

@synthesize delegate;

@synthesize request;

@synthesize client;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static PrivateWSService *sharedMyManager = nil;
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
        
        client = [[MMPReactiveStompClient alloc] initWithOutSocket];
        
        [self connect];
        
        self.dataService=[ZiPointDataService sharedManager];
        
    }
    return self;
}

-(void)connect {
    // channel=newChannel;
    
    [[client open:request]
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
         NSLog(@"web socket failed");
         [self reConnect];
     }
     completed:^{
         NSLog(@"web socket failed");
         [self reConnect];
     }];
    
}

-(void)setZiPointUser:(ZeePointUser *)ziPointUser{
    self.zeePointUser=ziPointUser;
}

-(ZeePointUser *) getZiPointUser{
    return self.zeePointUser;
}

-(void)subscribeZip{
    
    if (!self.connected){
        [self connect];
    }else{
        /*
        if (self.zeePoint){
            [self joinZiPoint];
            
            
        }*/
    }
}
/*
 -(void) channelConnected{
 
 }
 */
-(void)unSubscribeZip{
    self.oldestMessage=0;
    
    //[delegate finishReceivingMessageAnimatedNoScroll];
    if (self.connected){
        [client unSubscribe];
    }
}


-(void)reConnect{
    self.connected=FALSE;
    [delegate connecting:_dataService.loadingView];
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
    
    NSDictionary *dict = @{
                           @"message": message,
                           @"id": myMsgId,
                           //@"channel":self.zeePoint.referenceId,
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
    //[client sendMessage:body toDestination:[NSString stringWithFormat:STOMP_DESTINATION,self.zeePoint.referenceId]];
}



- (void)getPreviousMessages{
    NSString *zpointFinalURL;//=[NSString stringWithFormat:GET_PREVIOUS_MSGS,WS_ENVIROMENT,self.zeePoint.zpointId,[_dataService getUserId],self.oldestMessage];
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
             //NSArray *previousMessages=[self createZipointMessages:ziPointJoinInfo];
             
             //NSArray *messages=[ziPointJoinInfo objectForKey:@"zMessages"];
             
             //for (ZiPointMessage *message in previousMessages) {
                // [self receiveMessage:message putMessageAtFirst:true];
                 
             //}
             [delegate finishReceivingMessageAnimatedNoScroll];
         }
     }];
}

- (void)receiveWSMessage:(ZiPointMessage *)message
{
    //[self receiveMessage:message putMessageAtFirst:false];
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
    [delegate finishReceivingMessageAnimated:YES];
}
/*
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
            [self loadUserImage:message.userId faceBookId:message.fbId];
            
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
                [self imageMessageReceived:message];
                
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
}*/

-(void)imageMessageReceived:(ZiPointMessage*) message{
    
    if ([_dataService.images objectForKey:message.message]==nil){
        NSString *picFinalURL=message.message;
        NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        [self loadImageAsync:imageURL imageKey:message.message isImageForAmessage:true secondImageKey:nil];
        
    }else{
        for (JSQMessage *msg in _dataService.messages){
            if ([msg isMediaMessage] && [_dataService.images objectForKey:[msg text]] && !msg.received){
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[_dataService.images objectForKey:[msg text]]]];
                [msg setMedia:photoItem];
                msg.received=true;
            }
        }
        [delegate finishReceivingMessageAnimatedNoScroll];
    }
}

-(void)imageLoaded:(NSData *)imageData messageKey:(NSString *)key isImageForMessage:(bool)isMessage{
    if (isMessage){
        for (JSQMessage *msg in _dataService.messages){
            if ([msg isMediaMessage] && [_dataService.images objectForKey:key] && [[msg text] isEqualToString:key] && !msg.received){
                
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                if ([msg.senderId isEqual:_dataService.getUserId]){
                    [photoItem setAppliesMediaViewMaskAsOutgoing:YES];
                }else{
                    [photoItem setAppliesMediaViewMaskAsOutgoing:NO];
                }
                
                [msg setMedia:photoItem];
                msg.received=true;
                [delegate finishReceivingMessageAnimatedNoScroll];
            }
        }
    }else{
        //is avatar
        [_dataService.avatars setObject:[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault] forKey:key];
        [delegate finishReceivingMessageAnimatedNoScroll];
    }
    
}


-(void)loadUserImage:(NSString *) currentUserId faceBookId:(NSString *) currentFbId{
    if ([_dataService.images objectForKey:[currentUserId description]]==nil){
        NSString *picFinalURL=[NSString stringWithFormat:FB_USER_PIC,currentFbId];
        NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        [self loadImageAsync:imageURL imageKey:[currentUserId description] isImageForAmessage:false secondImageKey:nil];
        
    }
}

-(NSData *)loadImageAsync:(NSURL *)imageURL imageKey:(NSString *)key isImageForAmessage:(bool) isMessage secondImageKey:(NSString *)secKey{
    __block NSData *imageData;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized(key){
            if (![_dataService.images objectForKey:key]){
                imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData){
                        [_dataService.images setObject:imageData forKey:key];
                        if (secKey){
                            [_dataService.images setObject:imageData forKey:secKey];
                            [self imageLoaded:imageData messageKey:secKey isImageForMessage:isMessage];
                        }
                        [self imageLoaded:imageData messageKey:key isImageForMessage:isMessage];
                    }
                });
            }
        }
    });
    return imageData;
}
/*
- (void)joinZiPoint{
    [delegate connecting:_dataService.loadingView];
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
    
    
}*/

@end
