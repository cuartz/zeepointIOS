//
//  CreateZeePointViewController.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/5/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZeePointGroup.h"
#import <CoreLocation/CoreLocation.h>

//@protocol zeePointAdded <NSObject>

//-(void)createZeePoint:(NSString*)choosenZeePointName;

//@end
@interface CreateZeePointViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
//- (IBAction)fetchGreeting;
//- (IBAction)cancel:(id)sender;
//- (IBAction)save:(id)sender;
//@property (strong, nonatomic) IBOutlet UITextField *zeePointName;
//@property (retain)id <zeePointAdded> delegate;
//@property (strong, nonatomic)NSString *zeePointNameString;
@property ZeePointGroup *zeePointGroupItem;
@end
