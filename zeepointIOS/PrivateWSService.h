//
//  ZipOintService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZeePointUser.h"
#import "ZiPointMessage.h"

@class PrivateWSService;

@protocol PrivateWSServiceDelegatessage

-(void)connecting:(UIView *)loadingView;
-(void)didJustConnect;
-(void)finishReceivingMessageAnimatedNoScroll;


@end

@interface PrivateWSService : NSObject
@property (nonatomic, assign) id  delegate;
@property BOOL connected;
+ (id)sharedManager;

-(void)setZiPointUser:(ZeePointUser *)ziPointUser;

-(ZeePointUser *) getZiPointUser;

- (void)sendMessage:(NSString *)message
          messageId:(NSNumber *)myMsgId
        messageType:(NSString *)messageType;

- (void)getPreviousMessages;

@end
