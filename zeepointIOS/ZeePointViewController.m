//
//  ZeePointViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZeePointViewController.h"
#import "SWRevealViewController.h"
#import "Constants.h"
#import "JSQMessage.h"
#import "SWRevealViewController.h"
#import "ZeePointUser.h"

#import "ZiPointWSService.h"
#import "ZiPointDataService.h"
#import "UserNavigationController.h"
#import "ZiPointUserViewController.h"
#import "LoadImageService.h"


@interface ZeePointViewController () <ZiPointWSServiceDelegate>

//@property (weak, nonatomic) IBOutlet UINavigationItem *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sideBarButton;

@property ZiPointWSService *zipService;
@property ZiPointDataService *zipDataService;
@property LoadImageService *imageService;
@end


@implementation ZeePointViewController
@synthesize zipService;
@synthesize zipDataService;
//@synthesize imageService;
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    zipService = [ZiPointWSService sharedManager];
    zipDataService = [ZiPointDataService sharedManager];
    zipService.delegate=self;
    //imageService=[LoadImageService sharedManager];
    
    /**
     *  You MUST set your senderId and display name
     */
    self.senderId = [zipDataService getUserId];
    self.senderDisplayName = [zipDataService getUserName];
    
    
    /**
     *  Load up our fake data for the demo
     */
    
    
    
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
    

    //self.zeePointUsers=[[NSMutableSet alloc] init];
    
    //zipService.messages = [NSMutableArray new];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    //[self notAbleToParticipate];
    
    
    self.navigationItem.title=nil;
    
    if (zipService.getZiPoint){
    
    
    self.navigationItem.title=zipService.getZiPoint.name;
    
    /*if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }*/
    //self.demoData = [[DemoModelData alloc] init];
    

    //finishReceivingMessageAnimatedNoScroll
    //[zipService joinZiPoint];
    }
    
    //[self.navigationController setNavigationBarHidden: YES animated:NO];
    //ZeePointViewController *zeePointViewController = _frontViewController.childViewControllers[0];//stack[0];
    //if ( zeePointViewController )
    //{
        /*        ZiPointWSService *zipService = [ZiPointWSService sharedManager];
         zipService.zeePoint=self.zeePointJoined;
         zipService.lat=self.lat;
         zipService.lon=self.lon;*/
        
        //[self.revealViewController.navigationController setNavigationBarHidden: YES animated:NO];
        //zeePointViewController.navigationController=[self.navigationController  ;
    //}

}

- (void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    //self.title = zipService.zeePoint.name;
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    self.collectionView.collectionViewLayout.springinessEnabled = [NSUserDefaults springinessSetting];
    if (!zipService.getZiPoint){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No ZiPoint selected","No ZiPoint selected")
                                                        message:@"Join a ZiPoint by clicking on it from the search tab"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
        self.tabBarController.selectedIndex = 0;
    }
    //else
    [self checkEditable];
    //    [self connecting:zipService.loadingView];
    //}
    [self finishReceivingMessage];
    
}

- (void)viewDidDisappear:(BOOL)animated
{
}

/*
- (void)finishReceivingMessageCustom:(BOOL)animated{
    [self finishReceivingMessageAnimated:animated];
    [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
}*/

/*
- (void)closePressed:(UIBarButtonItem *)sender
{
    [self.delegateModal didDismissJSQDemoViewController:self];
}
*/



#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    NSNumber *myMsgid = @((NSUInteger)zipDataService.messages.count);
    [zipService sendMessage:text messageId:myMsgid messageType:TEXT_MESSAGE];
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

     
    
    [zipDataService.messages addObject:message];
    
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
    
    //[JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    //[self finishSendingMessageAnimated:YES];
}

- (void)addPhotoMediaMessage
{
    
    
    UIImagePickerController *imagePickController=[[UIImagePickerController alloc]init];
    imagePickController.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    imagePickController.delegate=self;
    imagePickController.allowsEditing=TRUE;
    [self presentViewController:imagePickController animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypePhotoLibrary])
    {
    UIImage *selectedImage = info[UIImagePickerControllerEditedImage];
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
    NSData *dataImage = UIImagePNGRepresentation(selectedImage);
    
 
        //UPLOAD CLAUDINARY IMAGE
        NSNumber *randomPublicId = [[NSNumber alloc] initWithInt:arc4random_uniform(99999999)];
        [zipService uploadImage:dataImage randomNumber:randomPublicId];
        
        //NSNumber *randomPublicId=[imageService uploadImage:dataImage];
        
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithMaskAsOutgoing:YES];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                   displayName:self.senderDisplayName
                                                         media:photoItem];
     
    [photoMessage setText:[randomPublicId description]];
    [zipDataService.messages addObject:photoMessage];
        [self finishReceivingMessageAnimatedNoScroll];
    }
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [zipDataService.messages objectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [zipDataService.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return zipDataService.outgoingBubbleImageData;
    }
    
    return zipDataService.incomingBubbleImageData;
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
    JSQMessage *message = [zipDataService.messages objectAtIndex:indexPath.item];
    
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
    
    
    return [zipDataService.avatars objectForKey:message.senderId];
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
        JSQMessage *message = [zipDataService.messages objectAtIndex:indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    JSQMessage *message = [zipDataService.messages objectAtIndex:indexPath.item];
    
    /**
     *  iOS7-style sender name labels
     */
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [zipDataService.messages objectAtIndex:indexPath.item - 1];
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
    return [zipDataService.messages count];
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
    
    JSQMessage *msg = [zipDataService.messages objectAtIndex:indexPath.item];
    
    if (!(BOOL*)msg.isMediaMessage) {
        
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
    JSQMessage *currentMessage = [zipDataService.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [zipDataService.messages objectAtIndex:indexPath.item - 1];
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
{
    [zipService getPreviousMessages];
    /*
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_PREVIOUS_MSGS,WS_ENVIROMENT,zipService.zeePoint.zpointId,[zipService getUserId],self.oldestMessage];
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
             NSArray *messages=[zipService createZipointMessages:ziPointJoinInfo];
             
             //NSArray *messages=[ziPointJoinInfo objectForKey:@"zMessages"];
             
             for (ZiPointMessage *message in messages) {
                 [self receiveMessage:message putMessageAtFirst:true];
                 
             }
             [self finishReceivingMessageAnimatedNoScroll];
         }
     }];*/
    
    //NSLog(@"Load earlier messages!");
}

- (void)finishReceivingMessageAnimatedNoScroll{
    
    self.showTypingIndicator = NO;
    
    [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
    [self.collectionView reloadData];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    //if ([zeePoint.distance intValue]>100 && !([zeePoint.ownerId isEqualToString:_zipService.getUserId])){
    //    [self performSegueWithIdentifier:@"showListenerRoom" sender:self];
    //}else{
        [self performSegueWithIdentifier:@"privateRoomSegue" sender:self];
    
    //[self.revealViewController performSegueWithIdentifier:@"revealPrivateRoom" sender:self];
    //}
    //NSLog(@"Tapped avatar!");
    
    //ZiPointUserViewController *mapViewController = [[ZiPointUserViewController alloc] init];
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    //UserNavigationController *navigationController = [[UserNavigationController alloc] initWithRootViewController:mapViewController];

    //[self.revealViewController pushFrontViewController:navigationController animated:YES];
    
    //[self.revealViewController.frontViewController.navigationController p
    
    //[self.revealViewController.rightViewController.navigationController pushViewController:navigationController animated:YES];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    //NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

-(void)didJustConnect{
    self.navigationItem.titleView=nil;
    self.navigationItem.title=zipService.getZiPoint.name;
    [self checkEditable];

    [self finishReceivingMessage];
}

-(void)checkEditable{
    if (zipService.isConnected && ([zipService.getZiPoint.distance intValue]<=100 || ([zipService.getZiPoint.ownerId isEqualToString:zipDataService.getUserId]))){
        [self ableToParticipate];
    }else{
        [self notAbleToParticipate];
    }
}

-(void)connecting{
    
    self.navigationItem.title=nil;
    
    [self notAbleToParticipate];
}

-(void)notAbleToParticipate{
    if (![zipService isConnected]){
        self.navigationItem.titleView =zipDataService.loadingView;
    }
    [self.inputToolbar.contentView.textView setEditable:false];
    if (self.inputToolbar.sendButtonOnRight) {
        self.inputToolbar.contentView.rightBarButtonItem.enabled=false;
        self.inputToolbar.contentView.leftBarButtonItem.enabled=false;
    }
    self.inputToolbar.contentView.textView.text=@"Come over to text here!";
    
}

-(void)ableToParticipate{
    [self.inputToolbar.contentView.textView setEditable:true];
    if (self.inputToolbar.sendButtonOnRight) {
        self.inputToolbar.contentView.rightBarButtonItem.enabled=true;
        self.inputToolbar.contentView.leftBarButtonItem.enabled=true;
    }
    self.inputToolbar.contentView.textView.text=@"";
}

- (IBAction)exitRoom:(id)sender {
    NSString *zpointFinalURL=[NSString stringWithFormat:EXIT_ZPOINT_SERVICE,WS_ENVIROMENT,zipService.getZiPoint.zpointId,zipDataService.getUserId];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *requestJoin = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:requestJoin
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             
             
             
         }
     }];
    self.tabBarController.selectedIndex = 0;
    [zipService setZiPoint:nil];
    
}

@end
