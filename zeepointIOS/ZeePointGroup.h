//
//  ZeePointGroup.h
//  ZeePoint
//
//  Created by Carlos Bayona on 3/30/15.
//  Copyright (c) 2015 systematis. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZeePointGroup : NSObject
    @property NSNumber *zpointId;
    @property NSString *name;
    @property NSString *referenceId;
    @property NSString *ownerId;
    @property BOOL joined;
    @property  NSNumber *users;
    @property  NSNumber *friends;
    @property  NSNumber *listeners;
    @property NSNumber *range;
    @property  NSNumber *distance;
    @property  BOOL *hiddenn;
    @property BOOL *favorite;

+(NSString *)getUsersLabelText: (NSNumber *)numberOfUsers
                  friendsParam:(NSNumber *)numberOfFriends
                listenersParam:(NSNumber *)numberOfListeners;

+(NSString *)getDistanceLabelText: (NSNumber *)distance;

+(UIColor *)getTitleLabelColor: (NSNumber *)distance senderId:(NSString*)senderId ownerId:(NSString*)ownerId;

+(UIFont *)getTitleFontStyle:(NSNumber *)friends;

+(UIColor *)getDistanceLabelColor: (NSNumber *)distance;

+(UIColor *)getJoinTitleLabelColor;

+(NSMutableArray *)loadInitialData;

+(UIFont *)getUsersFontStyle:(NSNumber *)friends;

+(UIFont *)getDistanceFontStyle:(NSNumber *)friends;

+(NSArray *) getSortDescriptors;

@end
