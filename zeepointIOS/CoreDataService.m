//
//  CoreDataService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/29/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "CoreDataService.h"
#import "AppDelegate.h"
#import "ZeePointUser.h"
#import "ZeePointGroup.h"

@interface CoreDataService()

@property (nonatomic, strong) CoreDataService *coreDataService;
@property (nonatomic, strong) AppDelegate *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext *context;

@end

@implementation CoreDataService

+ (id)sharedManager {
    static CoreDataService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        
        _appDelegate = [[UIApplication sharedApplication] delegate];
        
        _context = [_appDelegate managedObjectContext];
        
    }
    return self;
}

- (void)createZiPUser:(ZeePointUser *)zipUser
{
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ZiPUser" inManagedObjectContext:_context]];
    //[request setPredicate:[NSPredicate predicateWithFormat:@"userId = %@", zipUser.userId]];
     [request setFetchLimit:1];
     
     NSArray *results = [_context executeFetchRequest:request error:nil];
     
     //ZeePointUser* zipUser = nil;
     
     if ([results count] == 0)
     {
         //zipUser = // create the new here
         
         zipUser = [NSEntityDescription insertNewObjectForEntityForName:@"ZiPUser" inManagedObjectContext:_context];
         //[newDevice setValue:self.nameTextField.text forKey:@"name"];
         //[newDevice setValue:self.versionTextField.text forKey:@"version"];
         //[newDevice setValue:self.companyTextField.text forKey:@"company"];
         
         NSError *error = nil;
         // Save the object to persistent store
         if (![_context save:&error]) {
             NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
         }
     }
     else
     {
         zipUser = (ZeePointUser*)[results objectAtIndex:0];
     }
     
     //return zipUser;
     }

- (void)createZiPoint:(ZeePointGroup *)ziPoint
{
    
    
    
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ZiPoint" inManagedObjectContext:_context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"reference_id = %@", ziPoint.referenceId]];
    [request setFetchLimit:1];
    
    NSArray *results = [_context executeFetchRequest:request error:nil];
    
    //ZeePointUser* zipUser = nil;
    
    if ([results count] == 0)
    {
        //zipUser = // create the new here
        
        NSManagedObject	*ziPointEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ZiPoint" inManagedObjectContext:_context];
        [ziPointEntity setValue:ziPoint.zpointId forKey:@"id"];
        [ziPointEntity setValue:ziPoint.referenceId forKey:@"reference_id"];
        [ziPointEntity setValue:ziPoint.name forKey:@"name"];
        //[newDevice setValue:self.nameTextField.text forKey:@"name"];
        //[newDevice setValue:self.versionTextField.text forKey:@"version"];
        //[newDevice setValue:self.companyTextField.text forKey:@"company"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![_context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
}

- (NSArray*)searchZiPoints:(NSString *)ziPointName
{
    
    
    
    
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:@"ZiPoint" inManagedObjectContext:_context]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"name contains[c] %@", ziPointName]];
    [request setFetchLimit:1];
    
    NSArray *results = [_context executeFetchRequest:request error:nil];
    
    //ZeePointUser* zipUser = nil;
    
    if ([results count] == 0)
    {
        //zipUser = // create the new here
        
        NSManagedObject	*ziPointEntity = [NSEntityDescription insertNewObjectForEntityForName:@"ZiPoint" inManagedObjectContext:_context];
        //[ziPointEntity setValue:ziPoint.zpointId forKey:@"id"];
        //[ziPointEntity setValue:ziPoint.referenceId forKey:@"reference_id"];
        //[ziPointEntity setValue:ziPoint.name forKey:@"name"];
        //[newDevice setValue:self.nameTextField.text forKey:@"name"];
        //[newDevice setValue:self.versionTextField.text forKey:@"version"];
        //[newDevice setValue:self.companyTextField.text forKey:@"company"];
        
        NSError *error = nil;
        // Save the object to persistent store
        if (![_context save:&error]) {
            NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
        }
    }
    return nil;
}

@end
