//
//  ZeePointsViewController.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ZeePointsViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}
- (IBAction)unwindToList:(UIStoryboardSegue *)segue;

@end
