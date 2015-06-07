//
//  ZeePointUser.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 5/30/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSQMessages.h"

@interface ZeePointUser : NSObject

@property NSString *userId;
@property NSString *userName;
@property NSString *fbId;
@property NSString *gender;
@property NSString *history;
@property NSString *age;
@property JSQMessagesAvatarImage *userImage;

+(NSArray *) getSortDescriptors;

@end
