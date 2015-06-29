//
//  ZiPointDataService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/28/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZiPointDataService.h"
#import "ZiPointWSService.h"
#import "LoadingView.h"

@interface ZiPointDataService()

@property (nonatomic, strong) NSString *deviceToken;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSString *fbUserId;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) ZeePointGroup *zeePoint;
@property (nonatomic, strong) ZeePointUser *zeePointUser;
@property ZiPointDataService *zipService;

@end

@implementation ZiPointDataService
@synthesize delegate;
@synthesize loadingView;
@synthesize zeePointUsers;
@synthesize  avatars;
@synthesize  images;
@synthesize locationZiPoints;
@synthesize myZiPoints;
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

@synthesize  userId;
 */

+ (id)sharedManager {
    static ZiPointDataService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
        _userId=[prefs objectForKey:@"userId"];
        _fbUserId=[prefs objectForKey:@"fbUserId"];
        _email=[prefs objectForKey:@"email"];
        _deviceToken=[prefs objectForKey:@"DeviceToken"];
        _userName=[prefs objectForKey:@"name"];
        loadingView = [[LoadingView alloc] init];
        
        zeePointUsers=[[NSMutableSet alloc] init];
        avatars=[[NSMutableDictionary alloc] init];
        images=[[NSMutableDictionary alloc] init];
        
        locationZiPoints=[[NSMutableSet alloc] init];
        
        myZiPoints=[[NSMutableSet alloc] init];
        
        
        JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
        
        self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
        self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor colorWithRed:1 green:0.4 blue:0.106 alpha:1]];
        _messages = [NSMutableArray new];
        _privateMessages = [NSMutableDictionary new];
        
    }
    return self;
}

-(void)setDeviceToken:(NSString *) deviceToken{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:deviceToken forKey:@"DeviceToken"];
    _deviceToken=deviceToken;
}

-(NSString *) getDeviceToken{
    return _deviceToken;
}

-(void)setUserId:(NSString *) userId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:userId forKey:@"userId"];
    _userId=userId;
}

-(NSString *) getUserId{
    return _userId;
}

-(void)setFbUserId:(NSString *)fbUserId{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:fbUserId forKey:@"fbUserId"];
    _fbUserId=fbUserId;
}

-(NSString *) getFbUserId{
    return _fbUserId;
}

-(void)setEmail:(NSString *)email{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:email forKey:@"email"];
    _email=email;
}

-(NSString *) getEmail{
    return _email;
}

-(void)setUserName:(NSString *)name{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:name forKey:@"name"];
    _userName=name;
}

-(NSString *) getUserName{
    return _userName;
}

-(void)setGender:(NSString *)gender{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    [prefs setObject:gender forKey:@"gender"];
    _gender=gender;
}

-(NSString *) getGender{
    return _gender;
}


@end
