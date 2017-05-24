//
//  ZiPUser.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 8/8/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ZiPPrivateMessage;

@interface ZiPUser : NSManagedObject

@property (nonatomic, retain) NSNumber * fbId;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * userName;
@property (nonatomic, retain) NSOrderedSet *messages;
@end

@interface ZiPUser (CoreDataGeneratedAccessors)

- (void)insertObject:(ZiPPrivateMessage *)value inMessagesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMessagesAtIndex:(NSUInteger)idx;
- (void)insertMessages:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMessagesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMessagesAtIndex:(NSUInteger)idx withObject:(ZiPPrivateMessage *)value;
- (void)replaceMessagesAtIndexes:(NSIndexSet *)indexes withMessages:(NSArray *)values;
- (void)addMessagesObject:(ZiPPrivateMessage *)value;
- (void)removeMessagesObject:(ZiPPrivateMessage *)value;
- (void)addMessages:(NSOrderedSet *)values;
- (void)removeMessages:(NSOrderedSet *)values;
@end
