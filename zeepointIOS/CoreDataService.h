//
//  CoreDataService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/29/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZeePointUser.h"

@interface CoreDataService : NSObject

+ (id)sharedManager;

- (void)createZiPUser:(ZeePointUser *)zipUser;

@end
