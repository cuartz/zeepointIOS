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

@interface CreateZeePointViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
@property ZeePointGroup *zeePointGroupItem;
@end
