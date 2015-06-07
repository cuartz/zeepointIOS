//
//  ZipOintService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//
/*
#import "ZipOintService.h"

@implementation ZipOintService
@synthesize str;
@synthesize  zipUsers;
@synthesize  ziPoints;
@synthesize ziPointJoined;
@synthesize avatars;

static ZipOintService *instance = nil;

+(ZipOintService *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            instance= [ZipOintService new];
        }
    }
    return instance;
}

+(NSString) getUserName{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId=[prefs objectForKey:@"userId"];
    NSString *fbUserId=[prefs objectForKey:@"fbUserId"];
    NSString *email=[prefs objectForKey:@"email"];
}
@end
*/