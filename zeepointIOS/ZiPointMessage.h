//
//  ZiPointMessage.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/14/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZiPointMessage : NSObject

@property NSNumber *messageId;
@property NSString *time;
@property NSString *message;
@property NSString *channel;
@property NSString *userId;
@property NSString *userName;
@property NSString *fbId;
@property NSString *messageType;
@property NSNumber *tempId;

@end
