//
//  ZiPPrivateMessage.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 8/8/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZiPUser;

@interface ZiPPrivateMessage : NSManagedObject

@property (nonatomic, retain) NSNumber * fromUser;
@property (nonatomic, retain) NSString * message;
@property (nonatomic, retain) NSNumber * message_type;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) ZiPUser *from;

@end
