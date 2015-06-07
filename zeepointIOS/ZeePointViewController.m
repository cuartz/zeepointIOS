//
//  ZeePointViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZeePointViewController.h"
#import "SWRevealViewController.h"
#import <WebsocketStompKit/WebsocketStompKit.h>
#import "Constants.h"
#import "JSQMessage.h"
#import "SWRevealViewController.h"
#import "ZeePointUser.h"
#import "Cloudinary.h"

#define kHost     @"localhost"
#define kPort     8080

@interface ZeePointViewController () <CLUploaderDelegate>

@property NSString *username;
@property NSNumber *userId;
@property NSString *fbUserId;
//@property NSMutableSet *myMsgsIds;
@property (strong, nonatomic) NSMutableSet *zeePointUsers;
@property NSNumber *oldestMessage;
//@property NSNumber *alreadyProcessedMessage;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property CLCloudinary *cloudinary;

@end

@implementation ZeePointViewController


- (void)viewDidLoad
{
    self.cloudinary = [[CLCloudinary alloc] initWithUrl: CLOUDINARY_SERVICE];
    
    
    [super viewDidLoad];
    //self.toolbarHeightConstraint.constant = 0.0;
    
    //side bar code
    /*
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    SideBarController *uiViewController = [storyboard instantiateViewControllerWithIdentifier:@"SideBarView"];
    //uiViewController.sidebarButton=self.sideBarButton;
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [uiViewController.sideBarButton setTarget: self.revealViewController];
        [uiViewController.sideBarButton setAction: @selector( rightRevealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }*/
    //self.inputToolbar.contentView.leftBarButtonItem = nil;//self.sidebarButton;
    //side bar code
    
    //self.zeePointNameLabel.text=self.zeePoint.name;
    
    self.title = self.zeePoint.name;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    self.username=[prefs objectForKey:@"name"];
    self.userId=[prefs objectForKey:@"userId"];
    self.fbUserId=[prefs objectForKey:@"fbUserId"];
    //self.myMsgsIds=[[NSMutableSet alloc] init];
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [self.userId description];//kJSQDemoAvatarIdSquires;
    self.senderDisplayName = self.username;//kJSQDemoAvatarDisplayNameSquires;
    
    
    /**
     *  Load up our fake data for the demo
     */
    self.demoData = [[DemoModelData alloc] init];
    
    
    /**
     *  You can set custom avatar sizes
     */
    if (![NSUserDefaults incomingAvatarSetting]) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (![NSUserDefaults outgoingAvatarSetting]) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.showLoadEarlierMessagesHeader = YES;
/*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
*/
    /**
     *  Customize your toolbar buttons
     *
     *  self.inputToolbar.contentView.leftBarButtonItem = custom button or nil to remove
     *  self.inputToolbar.contentView.rightBarButtonItem = custom button or nil to remove
     */
    
    NSDictionary *headers = @{
                              @"content-type": @"application/json;charset=utf-8",
                              @"origin": @"http://localhost:8080"
                              };
    
    NSURL *websocketUrl = [NSURL URLWithString:@"ws://localhost:8080/chat/websocket"];
    self.client = [[STOMPClient alloc] initWithURL:websocketUrl webSocketHeaders:headers useHeartbeat:NO];//initWithURL:websocketUrl websocketHeaders:nil useHeartbeat:NO];
    
    
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBarButton setTarget: self.revealViewController];
        [self.sideBarButton setAction: @selector( rightRevealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    self.zeePointUsers=[[NSMutableSet alloc] init];
    

    NSString *zpointFinalURL=[NSString stringWithFormat:JOIN_ZPOINT_SERVICE,WS_ENVIROMENT,self.zeePoint.zpointId,self.userId,self.lat,self.lon];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             
             NSDictionary *ziPointJoinInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             
             NSArray *messages=[ziPointJoinInfo objectForKey:@"zMessages"];
             
             for (NSDictionary *message in messages) {
                 
                 //NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                 //id json = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
                 [self receiveMessage:message putMessageAtFirst:false];
             }
             [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
             [self finishReceivingMessageAnimated:YES];
             
             //[self populateTable:data];
             //[self receiveMessage:message];
             
             [self connect:nil messageId:nil];
         }
     }];
    
    //self.navBar.title=self.zeePoint.name;
 //self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
}



- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
{
    // build a static NSDateFormatter to display the current date in ISO-8601
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-d'T'HH:mm:ssZZZZZ";
    });
    
    // send the message to the truck's topic
    NSString *destination = @"/app/chat";//"//[NSString stringWithFormat:@"/topic/device.%@.location", @1];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSNumber *userId=[prefs objectForKey:@"userId"];
    // build a dictionary containing all the information to send

    NSDictionary *dict = @{
                           @"message": message,
                           @"id": myMsgId,
                           @"channel":self.zeePoint.referenceId,
                           @"userId":self.userId,
                           @"fbId":self.fbUserId,
                           @"userName":self.username
                           };
    // create a JSON string from this dictionary
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    NSString *body =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
 /*   NSDictionary *headers = @{
                              @"content-type": @"application/json;charset=utf-8",
                              @"origin": @"http://localhost:8080"
                              };
    */
    // send the message
    [self.client sendTo:destination
                //headers:headers
                   body:body];

}

- (void)sendMessageTry:(NSString *)message
       messageId:(NSNumber *)myMsgId
{
    if (![self.client connected]){
        [self connect:message messageId:myMsgId];
    }else{
        [self sendMessage:message messageId:myMsgId];
    }
}

- (void)connect:(NSString *)newMessage
      messageId:(NSNumber *)myMsgId
{
    NSLog(@"Connecting...");
    [self.client connectWithLogin:@"''" passcode:@"''"
                  completionHandler:^(STOMPFrame *connectedFrame, NSError *error) {
                      if (error) {
                          // We have not been able to connect to the broker.
                          // Let's log the error
                          NSLog(@"Error during connection: %@", error);
                      } else {
                          [self.client subscribeTo:[NSString stringWithFormat:@"/topic/channels/%@",self.zeePoint.referenceId] messageHandler:^(STOMPMessage *message) {
                              NSString *jsonString=[message body];
                              NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                              //id *json = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
                              NSDictionary *messageData=[NSJSONSerialization JSONObjectWithData:data
                                                              options:0
                                                                error:NULL];
                              [self receiveMessage:messageData putMessageAtFirst:false];
                              [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                              [self finishReceivingMessageAnimated:YES];
                          }];
                          // we are connected to the STOMP broker without an error
                          NSLog(@"Connected");
                          if (newMessage!=nil && [newMessage length]>0){
                              [self sendMessage:newMessage messageId:myMsgId];
                          }
                          //[self.client sendTo:@"/app/chat" body:@"{\"message\":\"iphone\",\"id\":821849,\"channel\":\"zp-1883563241\"}"];
                          
                      }
                  }];
    // when the method returns, we can not assume that the client is connected
}

- (void)receiveMessage:(NSDictionary *)message putMessageAtFirst:(BOOL *)atFirst
{
    
/*    NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
 */
     //NSLog(@"message: %@", message);
/*    NSDictionary *message = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
*/
    
    
    NSString *receivedMessage= [message objectForKey:@"message"];
    //NSLog(@"received message: %@", receivedMessage );
    NSNumber *newOldestMessage=[message objectForKey:@"messageId"];
    //if ([self.userId isEqualToNumber:[message objectForKey:@"userId"]] && [self.myMsgsIds containsObject:[message objectForKey:@"id"]] && (self.oldestMessage!=nil && (newOldestMessage!=nil && self.oldestMessage<=newOldestMessage))){
    if ([self.userId isEqualToNumber:[message objectForKey:@"userId"]] && ([message objectForKey:@"messageId"]==nil || [message objectForKey:@"messageId"]==(id)[NSNull null])){
       // YOUR MESSAGE HAS BEEN RECEIVED
        //[self.myMsgsIds removeObject:[message objectForKey:@"id"]];
        //[[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]]  setText:receivedMessage];
        if ([self.demoData.messages count] > [((NSNumber *)[message objectForKey:@"id"]) intValue] &&
           [[[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] text] isEqualToString:receivedMessage]){
            [[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] setReceived:(BOOL*)TRUE];
        }else{
            for (JSQMessage *msg in self.demoData.messages){
                if ([[msg text] isEqualToString:receivedMessage]){
                    [msg setReceived:(BOOL*)TRUE];
                    break;
                }
            }
        }
        //JSQMessage *msg=[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]];
        //msg.received=(BOOL*)TRUE;
        
    }else{// if(self.oldestMessage==nil || newOldestMessage==nil || self.oldestMessage<newOldestMessage){
        
        if (newOldestMessage!=nil && (self.oldestMessage==nil || self.oldestMessage>newOldestMessage)){
            self.oldestMessage=newOldestMessage;
        }
    
    ZeePointUser *checkUser=[[ZeePointUser alloc] init];
    checkUser.userId=[[message objectForKey:@"userId"] description];
    ZeePointUser *messageUser=[self.zeePointUsers member:checkUser];
    if (messageUser==nil){
     messageUser=[[ZeePointUser alloc] init];
        messageUser.userId=[[message objectForKey:@"userId"] description];//@"4";//(NSString *)[message objectForKey:@"userId"];
    messageUser.userName=[message objectForKey:@"userName"];
    messageUser.fbId=[message objectForKey:@"fbId"];
    messageUser.userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_cook"]
                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
        //[self.demoData.avatars setObject:messageUser.userImage forKey:messageUser.userId];
    
    NSString *picFinalURL=[NSString stringWithFormat:FB_USER_PIC,messageUser.fbId];
    NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                @try {
                // Update the UI
                //self.imageView.image = [UIImage imageWithData:imageData];
                messageUser.userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                                                                           diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                         [self.demoData.avatars setObject:messageUser.userImage forKey:messageUser.userId];
                    [self finishReceivingMessageAnimatedNoScroll];
                }
                @catch (NSException *exception) {
                    NSLog(@"%@", exception.reason);
                }
            });
        });
        
       // NSURL *imageURL = [NSURL URLWithString:@"http://example.com/demo.jpg"];
        /*
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 1), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Update the UI
                
                messageUser.userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                                                                      diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                [self.demoData.avatars setObject:messageUser.userImage forKey:messageUser.userId];
                [self.zeePointUsers addObject:messageUser];
          
            });
        });
        
        NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
        [NSURLConnection sendAsynchronousRequest:request
                                           queue:[NSOperationQueue mainQueue]
                               completionHandler:^(NSURLResponse *response,
                                                   NSData *imageData, NSError *connectionError)
         {
             if (imageData.length > 0 && connectionError == nil)
             {

                 messageUser.userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                 [self.demoData.avatars setObject:messageUser.userImage forKey:messageUser.userId];
                 [self.zeePointUsers addObject:messageUser];
             }
         }];*/
        
        
        
       // NSData *data = [NSData dataWithContentsOfURL:imageURL];
       // UIImage *img = [[UIImage alloc] initWithData:data];
       // messageUser.userImage = [JSQMessagesAvatarImageFactory avatarImageWithImage:img
         //                                                                  diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
        //[self.demoData.avatars setObject:messageUser.userImage forKey:messageUser.userId];

        [self.zeePointUsers addObject:messageUser];
        
        
        
        [self.demoData.users setObject:messageUser.userName forKey:messageUser.userId];
        
        
    }
    
    JSQMessage *newMessage =  [[JSQMessage alloc] initWithSenderId:messageUser.userId//kJSQDemoAvatarIdJobs
                                     senderDisplayName:messageUser.userName//self.demoData.users[randomUserId]
                                        date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[message objectForKey:@"time"] longValue] /1000.0]
                                            text:receivedMessage];
        newMessage.received=(BOOL*)TRUE;


/**
 *  Upon receiving a message, you should:
 *
 *  1. Play sound (optional)
 *  2. Add new id<JSQMessageData> object to your data source
 *  3. Call `finishReceivingMessage`
 */
        if (atFirst){
            [self.demoData.messages insertObject:newMessage atIndex:0];
        }else{
            [self.demoData.messages addObject:newMessage];
        }

        
    }

}

- (void)disconnect
{
    NSLog(@"Disconnecting...");
    [self.client disconnect];
    // when the method returns, we can not assume that the client is disconnected
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
    [self disconnect];
}

/*
#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}
*/
/*
#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    **
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     
    self.showTypingIndicator = !self.showTypingIndicator;
    
    **
     *  Scroll to actually view the indicator
     
    [self scrollToBottomAnimated:YES];
    
    **
     *  Copy last sent message, this will be the new "received" message
     
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    **
     *  Allow typing indicator to show
     
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            **
             *  Last message was a media message
     
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                **
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
     
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                **
                 *  Set location to nil to simulate "downloading" the location data
     
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                **
                 *  Reset video item to simulate "downloading" the video
     
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            **
             *  Last message was a text message
     
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        **
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
     
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        
        if (newMessage.isMediaMessage) {
            **
             *  Simulate "downloading" media
     
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                **
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
     
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}
*/
- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}




#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSNumber *myMsgid = @((NSUInteger)self.demoData.messages.count);
    //[self.myMsgsIds addObject:myMsgid];
    [self sendMessageTry:text messageId:myMsgid];
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:senderId
                                             senderDisplayName:senderDisplayName
                                                          date:date
                                                          text:text];

     
    
    [self.demoData.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Media messages"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:
                            @"Send photo"
                            ,@"Send location"
                            //, @"Send video"
                            , nil];
    
    [sheet showFromToolbar:self.inputToolbar];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.cancelButtonIndex) {
        return;
    }
    
    switch (buttonIndex) {
        case 0:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self addPhotoMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
        case 1:
        {
            __weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];
        }
            break;
            
/*        case 2:
            [self.demoData addVideoMediaMessage];
            break;*/
    }
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self finishSendingMessageAnimated:YES];
}

/*
- (void)addPhotoMediaMessage
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}*/
JSQMessage *photoMessage;
JSQPhotoMediaItem *photoItem;
- (void)addPhotoMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLUploader* uploader = [[CLUploader alloc] init:self.cloudinary delegate:self];
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"goldengate" ofType:@"png"];
    
    [uploader upload:imageFilePath options:@{}];
    
    //photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:NO];
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    photoItem.appliesMediaViewMaskAsOutgoing=FALSE;
    [self.demoData.messages addObject:photoMessage];

}


- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.demoData.messages addObject:photoMessage];
    [self finishSendingMessageAnimated:YES];
    NSString* publicId = [result valueForKey:@"public_id"];
    NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
}

- (void) uploaderError:(NSString *)result code:(NSInteger)code context:(id)context {
    NSLog(@"Upload error: %@, %ld", result, (long)code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
}

/*
- (void)addPhotoMediaMessage
{
    
    CLUploader* uploader = [[CLUploader alloc] init:self.cloudinary delegate:self];
    NSString *imageFilePath = [[NSBundle mainBundle] pathForResource:@"goldengate" ofType:@"png"];
    
    [uploader upload:imageFilePath options:@{}];
    
    
    
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.demoData.messages addObject:photoMessage];
}

*/



#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (![NSUserDefaults outgoingAvatarSetting]) {
            return nil;
        }
    }
    else {
        if (![NSUserDefaults incomingAvatarSetting]) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            if (!msg.received) {
                cell.textView.textColor = [UIColor grayColor];
            }else{
                cell.textView.textColor = [UIColor blackColor];
            }
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
        
    
    
    return cell;
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{/*
    
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                             senderDisplayName:self.senderDisplayName
                                                          date:[NSDate dateWithTimeIntervalSince1970:1432961871000 /1000.0]
                                                          text:@"mensaje anterior"];
    
    */
    
    
    
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_PREVIOUS_MSGS,WS_ENVIROMENT,self.zeePoint.zpointId,self.userId,self.oldestMessage];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             
             NSDictionary *ziPointJoinInfo = [NSJSONSerialization JSONObjectWithData:data
                                                                             options:0
                                                                               error:NULL];
             
             NSArray *messages=[ziPointJoinInfo objectForKey:@"zMessages"];
             
             for (NSDictionary *message in messages) {
                 
                 //NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
                 //id json = [NSJSONSerialization JSONObjectWithData:message options:0 error:nil];
                 [self receiveMessage:message putMessageAtFirst:(BOOL *)TRUE];
                 
             }
             [self finishReceivingMessageAnimatedNoScroll];
             
             //[JSQSystemSoundPlayer jsq_playMessageReceivedSound];
             //[self finishReceivingMessageAnimated:YES];
             
             //[self populateTable:data];
             //[self receiveMessage:message];
             
             //[self connect:nil messageId:nil];
         }
     }];
    
    
    
    
    
    
    //[self.demoData.messages addObject:message];
    
    
    NSLog(@"Load earlier messages!");
}

- (void)finishReceivingMessageAnimatedNoScroll{
    
    self.showTypingIndicator = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

@end
