//
//  ZipLocationService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/13/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ZipLocationService : NSObject <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

@end
