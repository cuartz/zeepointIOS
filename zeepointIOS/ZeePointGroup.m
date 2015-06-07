//
//  ZeePointGroup.m
//  ZeePoint
//
//  Created by Carlos Bayona on 3/30/15.
//  Copyright (c) 2015 systematis. All rights reserved.
//

#import "ZeePointGroup.h"
#import <UIKit/UIKit.h>

@implementation ZeePointGroup


+(NSString *)getUsersLabelText: (NSNumber *)numberOfUsers
                  friendsParam:(NSNumber *)numberOfFriends
                listenersParam:(NSNumber *)numberOfListeners{
    NSString *labelUsersValue=@"";
    NSString *labelFriendsValue=@"";
    NSString *labelListenersValue=@"";
    NSString *usersLabel=@" Users ";
    NSString *friendsLabel=@" Friends ";
    NSString *listenersLabel=@" listeners ";
    if ([numberOfUsers intValue]>0){
        labelUsersValue=[NSString stringWithFormat: @"%@%@", [numberOfUsers stringValue], usersLabel];
    }
    if ([numberOfFriends intValue]>0){
        labelFriendsValue=[NSString stringWithFormat: @"%@%@", [numberOfFriends stringValue], friendsLabel];
    }
    if ([numberOfListeners intValue]>0){
        labelListenersValue=[NSString stringWithFormat: @"%@%@", [numberOfListeners stringValue], listenersLabel];
    }
    return [NSString stringWithFormat: @"%@%@%@", labelUsersValue, labelFriendsValue, labelListenersValue];
}

+(NSString *)getDistanceLabelText: (NSNumber *)distance{
    NSString *unit=@" Mts";
    NSNumber *distanceValue=distance;
    if ([distance intValue]>999)
    {
        unit=@" Km";
        distanceValue=[NSNumber numberWithInt:[distance intValue]/1000];
    }
    if ([distance intValue]>99){
        return [NSString stringWithFormat: @"%@%@%@", @"At ", [distanceValue stringValue], unit];
    }else{
        return @"";
    }
}

+(UIColor *)getTitleLabelColor: (NSNumber *)distance{
    if ([distance intValue]<99){
        return [UIColor colorWithRed:14.0/255.0 green:194.0/255.0 blue:5.0/255.0 alpha:.9];
    }else {
        return [UIColor colorWithRed:1 green:0.4 blue:0.106 alpha:1];
        //return [UIColor blueColor];
    }
}

+(UIFont *)getTitleFontStyle:(NSNumber *)friends{
    if ([friends intValue]>0){
        return [UIFont boldSystemFontOfSize:16];
    }else{
        return [UIFont systemFontOfSize:16];
    }
}

+(UIFont *)getUsersFontStyle:(NSNumber *)friends{
    if ([friends intValue]>0){
        return [UIFont boldSystemFontOfSize:12];
    }else{
        return [UIFont systemFontOfSize:12];
    }
}

+(UIFont *)getDistanceFontStyle:(NSNumber *)friends{
    if ([friends intValue]>0){
        return [UIFont boldSystemFontOfSize:8];
    }else{
        return [UIFont systemFontOfSize:8];
    }
}

+(UIColor *)getDistanceLabelColor: (NSNumber *)distance{
    if ([distance intValue]<=125){
        return [UIColor colorWithRed:14.0/255.0 green:194.0/255.0 blue:5.0/255.0 alpha:.9];
    }else if ([distance intValue]<=150){
        return [UIColor orangeColor];
    }else {
        return [UIColor grayColor];
    }
}

+(UIColor *)getJoinTitleLabelColor{
    return [UIColor blackColor];
}

+(NSArray *) getSortDescriptors{
    return [NSArray arrayWithObjects:
            
            [NSSortDescriptor sortDescriptorWithKey:@"joined" ascending:NO selector:@selector(compare:)],
            
            [NSSortDescriptor sortDescriptorWithKey:@"distance" ascending:YES selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"friends" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"users" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"listeners" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)],
            
            nil];
}

+(NSMutableArray *)loadInitialData {
    
    NSMutableArray *zeePoints=[[NSMutableArray alloc] init];
    
    
    ZeePointGroup *item8 = [[ZeePointGroup alloc] init];
    item8.name = @"Tornados";
    item8.users = @3;
    item8.range = @20;
    item8.distance = @0;
    item8.friends = @1;
    item8.listeners = @0;
    //item8.hiddenn=@YES;
    [zeePoints addObject:item8];
    ZeePointGroup *item2 = [[ZeePointGroup alloc] init];
    item2.name = @"Wings Paseo";
    item2.users = @11;
    item2.friends = @0;
    item2.range = @10;
    item2.distance = @0;
    item2.listeners = @6;
    [zeePoints addObject:item2];
    
    ZeePointGroup *item4 = [[ZeePointGroup alloc] init];
    item4.name = @"Mc Donalds";
    item4.users = @3;
    item4.range = @10;
    item4.distance = @28;
    item4.listeners = @0;
    item4.friends = @0;
    [zeePoints addObject:item4];
    ZeePointGroup *item5 = [[ZeePointGroup alloc] init];
    item5.name = @"Pizzaly";
    item5.users = @0;
    item5.range = @10;
    item5.distance = @53;
    item5.listeners = @0;
    item5.friends = @0;
    [zeePoints addObject:item5];
    ZeePointGroup *item6 = [[ZeePointGroup alloc] init];
    item6.name = @"Soriana Jardines";
    item6.users = @37;
    item6.range = @30;
    item6.distance = @76;
    item6.listeners = @64;
    item6.friends = @4;
    [zeePoints addObject:item6];
    ZeePointGroup *item7 = [[ZeePointGroup alloc] init];
    item7.name = @"Holiday Inn";
    item7.users = @8;
    item7.range = @20;
    item7.distance = @101;
    item7.friends = @0;
    item7.listeners = @11;
    [zeePoints addObject:item7];
    ZeePointGroup *item1 = [[ZeePointGroup alloc] init];
    item1.name = @"Paseo Durango";
    item1.users = @78;
    item1.friends = @6;
    item1.range = @50;
    item1.distance = @0;
    item1.listeners = @211;
    item1.joined=YES;
    [zeePoints addObject:item1];
    ZeePointGroup *item3 = [[ZeePointGroup alloc] init];
    item3.name = @"ITD";
    item3.users = @251;
    item3.friends = @41;
    item3.range = @50;
    item3.distance = @11;
    item3.listeners = @496;
    [zeePoints addObject:item3];
    
    
    
    return zeePoints;
    
}

- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToZiPoint:other];
}

- (BOOL)isEqualToZiPoint:(ZeePointGroup *)zeePointGroup {
    if (self == zeePointGroup)
        return YES;
    if (![(id)[self zpointId] isEqual:[zeePointGroup zpointId]])
        return NO;
    return YES;
}

-(unsigned long)hash
{
    NSUInteger result = 1;
    NSUInteger prime = 31;
    result = prime * result + [_zpointId hash];
    
    return result;

}

@end
