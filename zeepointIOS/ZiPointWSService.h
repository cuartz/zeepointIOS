//
//  ZipOintService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZeePointGroup.h"

@class ZiPointWSService;

// define the protocol for the delegate
@protocol ZiPointWSServiceDelegate

// define protocol functions that can be used in any class using this delegate

-(void)receiveMessage:(NSDictionary *)message putMessageAtFirst:(BOOL *)atFirst;

-(void)connecting;

-(void)didJustConnect;

@end

@interface ZiPointWSService : NSObject {
    ZeePointGroup *zeePoint;
    double lat;
    double lon;
    
}
@property (nonatomic, strong) ZeePointGroup *zeePoint;
@property (nonatomic) double lat;
@property (nonatomic) double lon;
@property (nonatomic, assign) id  delegate;

// define public functions

+ (id)sharedManager;

- (void)sendMessage:(NSString *)body;

- (void)subscribeZip:(NSString *) newChannel;

//- (id)unsubscribe;

@end


/*
 
 prefs = [NSUserDefaults standardUserDefaults];
 *userId=[prefs objectForKey:@"userId"];
 NSString *fbUserId=[prefs objectForKey:@"fbUserId"];
 NSString *email=[prefs objectForKey:@"email"];
 }
 
 @property (retain) NSMutableArray *zipUsers;
 
 @property (nonatomic, retain) NSMutableArray *ziPoints;
 
 @property (nonatomic, retain) ZeePointGroup *ziPointJoined;
 
 @property (nonatomic, retain) NSMutableDictionary *avatars;
 
 @property (nonatomic, retain) NSString *userId;
 @property (nonatomic, retain) NSString *fbUserId;
 @property (nonatomic, retain) NSString *email;
 @property (nonatomic, retain) NSUserDefaults *prefs;
 
 //@property (strong, nonatomic) NSMutableDictionary *users;
 //@property(nonatomic,retain)NSString *str;
 +(ZipOintService*)getInstance;
 @end*/
