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
    @property BOOL joined;
    @property  NSNumber *users;
    @property  NSNumber *friends;
    @property  NSNumber *listeners;
    @property NSNumber *range;
    @property  NSNumber *distance;
    @property  BOOL *hiddenn;
    @property BOOL *favorite;
    //@property (readonly) NSDate *creationDate;

+(NSString *)getUsersLabelText: (NSNumber *)numberOfUsers
                  friendsParam:(NSNumber *)numberOfFriends
                listenersParam:(NSNumber *)numberOfListeners;

+(NSString *)getDistanceLabelText: (NSNumber *)distance;

+(UIColor *)getTitleLabelColor: (NSNumber *)distance;

+(UIFont *)getTitleFontStyle:(NSNumber *)friends;

+(UIColor *)getDistanceLabelColor: (NSNumber *)distance;

+(UIColor *)getJoinTitleLabelColor;

+(NSMutableArray *)loadInitialData;

+(UIFont *)getUsersFontStyle:(NSNumber *)friends;

+(UIFont *)getDistanceFontStyle:(NSNumber *)friends;

+(NSArray *) getSortDescriptors;

//getGroupTitleLabelColor //obtiene el color del titulo dependiendo de la distancia a la que esta el grupo

//getDistanceLabeColor //

//isGroupTitleBold->doGroupHaveFriends

//getUsersLabel->doGroupHaveUsers ->doGroupHaveFriends->doGroupHaveListeners
@end
