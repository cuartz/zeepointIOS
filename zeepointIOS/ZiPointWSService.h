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

-(void)receiveWSMessage:(ZiPointMessage *)message;

-(void)connecting:(UIView *)loadingView;

-(void)imageLoaded:(NSData *)imageData messageKey:(NSString *)key isImageForMessage:(bool) isMessage;

-(void)didJustConnect;

@end

@interface ZiPointWSService : NSObject {
    ZeePointGroup *zeePoint;
    NSMutableSet *zeePointUsers;
    double lat;
    double lon;
    NSMutableDictionary *avatars;
    NSMutableDictionary *images;
    
}
@property (nonatomic, strong) ZeePointGroup *zeePoint;
@property (nonatomic, strong) NSMutableSet *zeePointUsers;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, assign) id  delegate;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) NSMutableDictionary *images;

// define public functions

+ (id)sharedManager;

- (void)sendMessage:(NSString *)body;

- (void)subscribeZip:(NSString *) newChannel;

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

-(ZeePointGroup *)createZipointGroup:(NSDictionary *)dict;

-(NSMutableSet *)createZipointGroups:(NSDictionary *)dict;

-(NSMutableSet *)createZipointUsers:(NSDictionary *)dict;

-(ZeePointUser *)createZipointUser:(NSDictionary *)dict;

-(ZiPointMessage *)createZipointMessage:(NSDictionary *)dict;

-(NSMutableArray *)createZipointMessages:(NSDictionary *)dict;

//- (id)unsubscribe;

@end