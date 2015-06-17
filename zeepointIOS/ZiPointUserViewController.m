//
//  ZeePointViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZiPointUserViewController.h"
#import "SWRevealViewController.h"
#import <WebsocketStompKit/WebsocketStompKit.h>
#import "Constants.h"
#import "JSQMessage.h"
#import "SWRevealViewController.h"
#import "ZeePointUser.h"
#import "Cloudinary.h"
#import "ZiPointWSService.h"


@interface ZiPointUserViewController () <CLUploaderDelegate, ZiPointWSServiceDelegate>

@property (strong, nonatomic) NSMutableSet *zeePointUsers;
@property int oldestMessage;
@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;
@property CLCloudinary *cloudinary;
@property ZiPointWSService *zipService;

@end


@implementation ZiPointUserViewController
@synthesize zipService;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    zipService = [ZiPointWSService sharedManager];
    zipService.delegate=self;
    
    self.cloudinary = [[CLCloudinary alloc] initWithUrl: CLOUDINARY_SERVICE];
    
    self.title = zipService.zeePoint.name;
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [zipService getUserId];//kJSQDemoAvatarIdSquires;
    self.senderDisplayName = [zipService getUserId];//kJSQDemoAvatarDisplayNameSquires;
    
    
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
    
    SWRevealViewController *revealViewController = self.revealViewController;
    if ( revealViewController )
    {
        [self.sideBarButton setTarget: self.revealViewController];
        [self.sideBarButton setAction: @selector( rightRevealToggle: )];
        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
    }
    
    
    self.zeePointUsers=[[NSMutableSet alloc] init];
    
    
    NSString *zpointFinalURL=[NSString stringWithFormat:JOIN_ZPOINT_SERVICE,WS_ENVIROMENT,zipService.zeePoint.zpointId,zipService.getUserId,zipService.lat,zipService.lon];
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
             
             //[self connect:nil messageId:nil messageType:nil];
             [zipService subscribeZip:zipService.zeePoint.referenceId];
         }
     }];
    
    //self.navBar.title=self.zeePoint.name;
    //self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    
}



- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
        messageType:(NSString *)messageType
{
    // build a static NSDateFormatter to display the current date in ISO-8601
    static NSDateFormatter *dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-d'T'HH:mm:ssZZZZZ";
    });
    
    // send the message to the truck's topic
    //NSString *destination = @"/app/chat";//"//[NSString stringWithFormat:@"/topic/device.%@.location", @1];
    //NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //NSNumber *userId=[prefs objectForKey:@"userId"];
    // build a dictionary containing all the information to send
    
    NSDictionary *dict = @{
                           @"message": message,
                           @"id": myMsgId,
                           @"channel":zipService.zeePoint.referenceId,
                           @"userId":zipService.getUserId,
                           @"fbId":zipService.getFbUserId,
                           @"userName":zipService.getUserName,
                           @"messageType":messageType
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
    [zipService sendMessage:body];
    
}

- (void)sendMessageTry:(NSString *)message
             messageId:(NSNumber *)myMsgId
           messageType:(NSString *)messageType
{
    [self sendMessage:message messageId:myMsgId
          messageType:messageType];
}
/*
 - (void)connect:(NSString *)newMessage
 messageId:(NSNumber *)myMsgId
 messageType:(NSString *)messageType
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
 [self sendMessage:newMessage messageId:myMsgId
 messageType:messageType];
 }
 //[self.client sendTo:@"/app/chat" body:@"{\"message\":\"iphone\",\"id\":821849,\"channel\":\"zp-1883563241\"}"];
 
 }
 }];
 
 // when the method returns, we can not assume that the client is connected
 }*/

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
    if ([zipService.getUserId isEqual:[message objectForKey:@"userId"]] && ([message objectForKey:@"messageId"]==nil || [message objectForKey:@"messageId"]==(id)[NSNull null])){
        // YOUR MESSAGE HAS BEEN RECEIVED
        //[self.myMsgsIds removeObject:[message objectForKey:@"id"]];
        //[[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]]  setText:receivedMessage];
        if ([self.demoData.messages count] > [((NSNumber *)[message objectForKey:@"id"]) intValue] &&
            [[[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] text] isEqualToString:receivedMessage] &&
            [[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] received]==FALSE){
            [[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] setReceived:(BOOL*)TRUE];
            /*            if ([[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] isMediaMessage]){
             
             [[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]] setMedia:[self.demoData.images objectForKey:receivedMessage]];
             }*/
            
            
        }else{
            for (JSQMessage *msg in self.demoData.messages){
                if ([msg isMediaMessage] && ![msg received]){
                    [msg setReceived:(BOOL*)TRUE];
                    [msg setMedia:[zipService.images objectForKey:receivedMessage]];
                } else if ([[msg text] isEqualToString:receivedMessage] && ![msg received]){
                    [msg setReceived:(BOOL*)TRUE];
                    break;
                }
            }
        }
        //JSQMessage *msg=[self.demoData.messages objectAtIndex:[((NSNumber *)[message objectForKey:@"id"]) intValue]];
        //msg.received=(BOOL*)TRUE;
        
    }else{// if(self.oldestMessage==nil || newOldestMessage==nil || self.oldestMessage<newOldestMessage){
        
        if (newOldestMessage!=nil && newOldestMessage!=(id)[NSNull null] && (self.oldestMessage==0 || self.oldestMessage>[newOldestMessage intValue])){
            self.oldestMessage=[newOldestMessage intValue];
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
                        [zipService.avatars setObject:messageUser.userImage forKey:messageUser.userId];
                        [self finishReceivingMessageAnimatedNoScroll];
                    }
                    @catch (NSException *exception) {
                        NSLog(@"%@", exception.reason);
                    }
                });
            });
            
            [self.zeePointUsers addObject:messageUser];
            
            
            
            //[self.demoData.users setObject:messageUser.userName forKey:messageUser.userId];
            
            
        }
        
        JSQMessage *newMessage;
        if ([[[message objectForKey:@"messageType"] description] isEqualToString:PHOTO_MESSAGE]){
            JSQPhotoMediaItem *photoItem;
            if ([zipService.images objectForKey:receivedMessage]==nil){
                if ([messageUser.userId isEqual:self.senderId]){
                    photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
                }else{
                    photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:NO];
                }
                newMessage=  [[JSQMessage alloc] initWithSenderId:messageUser.userId//kJSQDemoAvatarIdJobs
                                                senderDisplayName:messageUser.userName//self.demoData.users[randomUserId]
                                                             date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[message objectForKey:@"time"] longValue] /1000.0]
                                                            media:photoItem];
                NSString *picFinalURL=receivedMessage;
                NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            
                            //JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                            [photoItem setImage:[UIImage imageWithData:imageData]];
                            [zipService.images setObject:photoItem forKey:receivedMessage];
                            
                            //for (JSQMessage *msg in self.demoData.messages){
                            //    if ([msg isMediaMessage] && [self.demoData.images objectForKey:[msg text]]){
                            
                            // [newMessage setMedia:[self.demoData.images objectForKey:receivedMessage]];
                            //    }
                            //}
                            
                            
                            [self finishReceivingMessageAnimatedNoScroll];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"%@", exception.reason);
                        }
                    });
                });
            }else{
                photoItem=[zipService.images objectForKey:receivedMessage];
                newMessage=  [[JSQMessage alloc] initWithSenderId:messageUser.userId//kJSQDemoAvatarIdJobs
                                                senderDisplayName:messageUser.userName//self.demoData.users[randomUserId]
                                                             date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[message objectForKey:@"time"] longValue] /1000.0]
                                                            media:photoItem];
            }
            
            
        }else{
            newMessage=  [[JSQMessage alloc] initWithSenderId:messageUser.userId//kJSQDemoAvatarIdJobs
                                            senderDisplayName:messageUser.userName//self.demoData.users[randomUserId]
                                                         date:[NSDate dateWithTimeIntervalSince1970:[(NSNumber *)[message objectForKey:@"time"] longValue] /1000.0]
                                                         text:receivedMessage];
        }
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
        
        if ([message objectForKey:@"messageType"]==PHOTO_MESSAGE){
            if ([zipService.images objectForKey:receivedMessage]==nil){
                NSString *picFinalURL=receivedMessage;
                NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        @try {
                            
                            JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                            [zipService.images setObject:photoItem forKey:receivedMessage];
                            
                            for (JSQMessage *msg in self.demoData.messages){
                                if ([msg isMediaMessage] && [zipService.images objectForKey:[msg text]]){
                                    
                                    [msg setMedia:[zipService.images objectForKey:[msg text]]];
                                }
                            }
                            
                            
                            [self finishReceivingMessageAnimatedNoScroll];
                        }
                        @catch (NSException *exception) {
                            NSLog(@"%@", exception.reason);
                        }
                    });
                });
                
            }else{
                for (JSQMessage *msg in self.demoData.messages){
                    if ([msg isMediaMessage] && [zipService.images objectForKey:[msg text]]){
                        
                        [msg setMedia:[zipService.images objectForKey:[msg text]]];
                    }
                }
            }
        }
        
        
        
    }
    
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
}

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
    [self sendMessageTry:text messageId:myMsgid messageType:TEXT_MESSAGE];
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
            
            [self addPhotoMediaMessage];
        }
            break;
            
        case 1:
        {
            /*__weak UICollectionView *weakView = self.collectionView;
            
            [self.demoData addLocationMediaMessageCompletion:^{
                [weakView reloadData];
            }];*/
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

- (void)addPhotoMediaMessage
{
    
    
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=TRUE;
    //imagePickController.mediaTypes=@[kUTTypeImage]
    //[[NSArray alloc] initWithObjects: (NSString *) kUTTypeImage, nil];
    [self presentViewController:imagePickController animated:YES completion:NULL];
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
        
        // NSURL *imageFileURL = [info objectForKey:UIImagePickerControllerReferenceURL];
        
        //self.imageView.image = selectedImage;
        [picker dismissViewControllerAnimated:YES completion:NULL];
        
        NSData *dataImage = UIImagePNGRepresentation(selectedImage);
        
        /*
         NSData *webData = UIImagePNGRepresentation(selectedImage);
         NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
         NSString *documentsDirectory = [paths objectAtIndex:0];
         NSString *localFilePath = [documentsDirectory stringByAppendingPathComponent:@"png"];//;// stringByAppendingPathComponent:png];
         [webData writeToFile:localFilePath atomically:YES];
         */
        
        //NSString *localFile=@"goldengate";
        
        CLUploader* uploader = [[CLUploader alloc] init:self.cloudinary delegate:self];
        
        //NSString *imageFilePath = selectedImage;//[[NSBundle mainBundle] pathForResource:localFile ofType:@"png"];
        
        
        CLTransformation *transformation = [CLTransformation transformation];
        [transformation setWidthWithInt: 210];
        [transformation setHeightWithInt: 150];
        [transformation setCrop: @"fill"];
        NSNumber *randomPublicId = [[NSNumber alloc] initWithInt:arc4random_uniform(99999999)];
        [uploader upload:dataImage options:@{@"resource_type": @"auto",@"transformation": transformation,@"public_id": randomPublicId}];
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
        //JSQMessage *photoMessage;
        //JSQPhotoMediaItem *photoItem;
        
        //JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:localFile]];
        JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                       displayName:self.senderDisplayName
                                                             media:photoItem];
        [photoMessage setText:[randomPublicId description]];
        //photoItem.appliesMediaViewMaskAsOutgoing=FALSE;
        [self.demoData.messages addObject:photoMessage];
        [self finishReceivingMessageAnimatedNoScroll];
    }
}
//localFilePath	NSPathStore2 *	@"/Users/cuartz/Library/Developer/CoreSimulator/Devices/6DDFC138-4E1B-4BAB-B403-163EAC968F60/data/Containers/Data/Application/F1285939-C21C-4BE2-820A-22B97DC7C2CC/Documents/png"	0x00007fb0b3d52300
//documentsDirectory	NSPathStore2 *	@"/Users/cuartz/Library/Developer/CoreSimulator/Devices/6DDFC138-4E1B-4BAB-B403-163EAC968F60/data/Containers/Data/Application/EA777CD4-DD2E-48B5-AFA5-D61CEC1959D1/Documents"	0x00007fed5df56670





- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    
    
    NSString* fileName = [result valueForKey:@"public_id"];
    NSString* urlMessage = [result valueForKey:@"url"];
    
    NSString *picFinalURL=urlMessage;
    NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            @try {
                
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                
                [zipService.images setObject:photoItem forKey:urlMessage];
                [zipService.images setObject:photoItem forKey:fileName];
                NSNumber *myMsgid = @((NSUInteger)self.demoData.messages.count);
                [self sendMessageTry:urlMessage messageId:myMsgid messageType:PHOTO_MESSAGE];
                //[self finishReceivingMessageAnimatedNoScroll];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.reason);
            }
        });
    });
    
    
    //[self.myMsgsIds addObject:myMsgid];
    
    
    
    
    
    /*
     
     for (JSQMessage *msg in self.demoData.messages){
     if ([[msg localFile] isEqualToString:fileName] && [[msg senderId] isEqual:self.senderId]){
     
     [msg setMedia:photoItem];
     //break;
     }
     }
     JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
     displayName:self.senderDisplayName
     media:photoItem];
     [self.demoData.messages addObject:photoMessage];*/
    
    /*
     
     
     photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
     photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
     displayName:kJSQDemoAvatarDisplayNameSquires
     media:photoItem];
     [self.demoData.messages addObject:photoMessage];
     [self finishSendingMessageAnimated:YES];*/
    //NSString* publicId = [result valueForKey:@"public_id"];
    //NSLog(@"Upload success. Public ID=%@, Full result=%@", publicId, result);
    //[self finishReceivingMessageAnimatedNoScroll];
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
    
    
    return [zipService.avatars objectForKey:message.senderId];
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
    
    
    
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_PREVIOUS_MSGS,WS_ENVIROMENT,zipService.zeePoint.zpointId,zipService.getUserId,self.oldestMessage];
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

-(void)didJustConnect{
    NSLog(@"didJustConnect");
}

-(void)connecting{
    NSLog(@"connecting....");
}

@end
