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

-(void)connecting:(UIView *)loadingView;

//-(void)imageLoaded:(NSData *)imageData messageKey:(NSString *)key isImageForMessage:(bool) isMessage;

-(void)didJustConnect;

//-(void)receiveMessage:(ZiPointMessage *)message putMessageAtFirst:(bool)atFirst;

-(void)finishReceivingMessageCustom:(BOOL)animated;

-(void)finishReceivingMessageAnimatedNoScroll;

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
@property (strong, nonatomic) NSMutableSet *locationZiPoints;
@property (strong, nonatomic) NSMutableSet *myZiPoints;
@property (nonatomic, strong) NSMutableSet *zeePointUsers;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, assign) id  delegate;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) NSMutableDictionary *images;

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

// define public functions

+ (id)sharedManager;

-(void)setZiPoint:(ZeePointGroup *)ziPoint;

-(ZeePointGroup *) getZiPoint;

//- (void)sendMessage:(NSString *)body;

- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
        messageType:(NSString *)messageType;

- (void)getPreviousMessages;

//- (void)subscribeZip;

-(NSData *)loadImageAsync:(NSURL *)imageURL imageKey:(NSString *)key isImageForAmessage:(bool)isMessage secondImageKey:(NSString *)secKey;

-(void)setDeviceToken:(NSString *) deviceToken;

-(NSString *) getDeviceToken;

-(void)setUserId:(NSString *) userId;

-(NSString *) getUserId;

-(void)setFbUserId:(NSString *)fbUserId;

-(NSString *) getFbUserId;

-(void)setEmail:(NSString *)email;

-(NSString *) getEmail;

-(void)setUserName:(NSString *)name;

-(NSString *) getUserName;

-(void)setGender:(NSString *)gender;

-(NSString *) getGender;

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
