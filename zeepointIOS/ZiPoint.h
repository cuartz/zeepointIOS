//
//  ZiPoint.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 8/8/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZiPUser;

@interface ZiPoint : NSManagedObject

@property (nonatomic, retain) NSNumber * city_id;
@property (nonatomic, retain) NSNumber * country_id;
@property (nonatomic, retain) NSNumber * creator;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSDecimalNumber * latitud;
@property (nonatomic, retain) NSDecimalNumber * longitud;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * reference_id;
@property (nonatomic, retain) NSNumber * state_id;
@property (nonatomic, retain) ZiPUser *owner;

@end
