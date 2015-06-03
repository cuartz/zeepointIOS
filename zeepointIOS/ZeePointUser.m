//
//  ZeePointUser.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 5/30/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZeePointUser.h"

@implementation ZeePointUser



- (BOOL)isEqual:(id)other {
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:[self class]])
        return NO;
    return [self isEqualToZiPUser:other];
}

- (BOOL)isEqualToZiPUser:(ZeePointUser *)zeePointUser {
    if (self == zeePointUser)
        return YES;
    if (![(id)[self userId] isEqual:[zeePointUser userId]])
        return NO;
    return YES;
}

-(unsigned long)hash
{
    NSUInteger result = 1;
    NSUInteger prime = 31;
    result = prime * result + [_userId hash];
    
    return result;
    
}


+(NSArray *) getSortDescriptors{
    return [NSArray arrayWithObjects:
            
            [NSSortDescriptor sortDescriptorWithKey:@"friend" ascending:NO selector:@selector(compare:)],
            
            [NSSortDescriptor sortDescriptorWithKey:@"ownder" ascending:YES selector:@selector(compare:)],
            
            [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"friends" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"users" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"listeners" ascending:NO selector:@selector(compare:)],
            
            //[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(compare:)],
            
            nil];
}

@end
