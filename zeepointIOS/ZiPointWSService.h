//
//  ZipOintService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZeePointGroup.h"
#import "ZeePointUser.h"
#import "ZiPointMessage.h"

@class ZiPointWSService;

@protocol ZiPointWSServiceDelegate

// define protocol functions that can be used in any class using this delegate

//-(void)receiveWSMessage:(ZiPointMessage *)message;

-(void)connecting;

//-(void)imageLoaded:(NSData *)imageData messageKey:(NSString *)key isImageForMessage:(bool) isMessage;

-(void)didJustConnect;

//-(void)receiveMessage:(ZiPointMessage *)message putMessageAtFirst:(bool)atFirst;

//-(void)finishReceivingMessageCustom:(BOOL)animated;

-(void)finishReceivingMessageAnimatedNoScroll;

//-(void)finishReceivingMessageAnimated:(BOOL)animated;

@end

@interface ZiPointWSService : NSObject
/*{
    ZeePointGroup *zeePoint;
    NSMutableSet *zeePointUsers;
    double lat;
    double lon;
    NSMutableDictionary *avatars;
    NSMutableDictionary *images;
    
}*/
//@property (nonatomic, strong) ZeePointGroup *zeePoint;
//@property (strong, nonatomic) NSMutableSet *locationZiPoints;
//@property (strong, nonatomic) NSMutableSet *myZiPoints;
//@property (nonatomic, strong) NSMutableSet *zeePointUsers;
//@property (nonatomic) double lat;
//@property (nonatomic) double lon;
@property (nonatomic, assign) id  delegate;
//@property (strong, nonatomic) NSMutableDictionary *avatars;
//@property (strong, nonatomic) NSMutableDictionary *images;
@property BOOL connected;
//@property (nonatomic, strong) UIView *loadingView;
//@property (strong, nonatomic) NSMutableArray *messages;

//@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

//@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

// define public functions

+ (id)sharedManager;

- (BOOL)isConnected;

-(void)setZiPoint:(ZeePointGroup *)ziPoint;

-(ZeePointGroup *) getZiPoint;

//-(void)setZiPoint:(ZeePointGroup *)ziPoint;

//-(ZeePointGroup *) getZiPoint;

//-(void)setZiPointUser:(ZeePointUser *)ziPointUser;

//-(ZeePointUser *) getZiPointUser;

//- (void)sendMessage:(NSString *)body;

-(void)uploadImage:(NSData *)dataImage randomNumber:(NSNumber *)randomPublicId;

- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
        messageType:(NSString *)messageType;

- (void)getPreviousMessages;

//- (void)subscribeZip;

//-(NSData *)loadImageAsync:(NSURL *)imageURL imageKey:(NSString *)key isImageForAmessage:(bool)isMessage secondImageKey:(NSString *)secKey;

-(ZeePointGroup *)createZipointGroup:(NSDictionary *)dict;

-(NSMutableSet *)createZipointGroups:(NSDictionary *)dict;

-(NSMutableSet *)createZipointUsers:(NSDictionary *)dict;

-(ZeePointUser *)createZipointUser:(NSDictionary *)dict;

-(ZiPointMessage *)createZipointMessage:(NSDictionary *)dict;

-(NSMutableArray *)createZipointMessages:(NSDictionary *)dict;

- (void)saveUserInfo:(NSString *) fbUserId :(NSString *)deviceToken;

- (void)joinZiPoint;

//- (id)unsubscribe;

@end
