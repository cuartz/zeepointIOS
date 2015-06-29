//
//  ZiPointDataService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/28/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZeePointGroup.h"
#import "ZeePointUser.h"
#import "ZiPointMessage.h"

@class ZiPointWSService;

@protocol ZiPointDataServiceDelegate

-(void)unSubscribeZip;

-(void)subscribeZip;

@end

@interface ZiPointDataService : NSObject

@property (strong, nonatomic) NSMutableSet *locationZiPoints;
@property (strong, nonatomic) NSMutableSet *myZiPoints;
@property (nonatomic, strong) NSMutableSet *zeePointUsers;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) NSMutableDictionary *images;
@property (nonatomic, strong) UIView *loadingView;
@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSMutableDictionary *privateMessages;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (nonatomic, assign) id  delegate;


+ (id)sharedManager;

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

@end
