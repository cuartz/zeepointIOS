//
//  CreateZeePointViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/5/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "CreateZeePointViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "ZeePointsViewController.h"
#import "ZeePointGroup.h"
#import "Constants.h"

@interface CreateZeePointViewController () <CLLocationManagerDelegate>
//@property ZeePointGroup *zeePoint;
//@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (weak, nonatomic) IBOutlet UITextField *zeePointNameTextField;
@property CLGeocoder *geocoder;
@property double lat;
@property double lon;
@property NSString *country;
@property NSString *state;
@property NSString *city;

@end

@implementation CreateZeePointViewController
/*{
    CLLocationManager *manager;
    CLGeocoder *geocoder;
    CLPlacemark *placemark;
}*/

NSString *tempZpointName;

//@synthesize delegate, zeePointNameString, zeePointName;

- (IBAction)fetchGreeting;
{
    
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];
    
    [activityIndicator startAnimating];
    
    //[activityIndicator removeFromSuperview];
    

}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.lat=self.lon=0;
    
    locationManager = [[CLLocationManager alloc] init];

    
 //   [self fetchGreeting];
    
    locationManager.delegate = self;
    //locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
}
- (IBAction)saveButton:(id)sender {
/*    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"Getting your location, please wait..." delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
    [alert addSubview:activityIndicator];
    activityIndicator.center = CGPointMake(self.view.frame.size.width / 2.0, self.view.frame.size.height / 2.0);
    [self.view addSubview: activityIndicator];
 
    [activityIndicator startAnimating];
    [alert show];*/
    [self createZpoint];
    
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)locationButton:(id)sender {
    
    locationManager.delegate = self;
    //locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    
    [locationManager startUpdatingLocation];
    
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    //if (sender != self.saveButton) return;
    
    

    //[activityIndicator  startAnimating];
    
//    while (activityIndicator.areAnimationsEnabled) {
//        <#statements#>
//    }
    
    //[activityIndicator removeFromSuperview];
    
    //if (self.zeePointNameTextField.text.length > 0) {
    //    self.zeePointGroupItem = [[ZeePointGroup alloc] init];
    //    self.zeePointGroupItem.name=self.zeePointNameTextField.text;
    //}

}

-(BOOL)createZpoint{
    if (self.lat==0 || self.lon==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 010"
                                                        message:@"Unable to get your location, go to www.zipoints.com and report it so we start fixing it!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }else{
    [locationManager stopUpdatingLocation];
    if(self.zeePointNameTextField.text.length>0){
        tempZpointName=self.zeePointNameTextField.text;
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *fbUserId=[prefs objectForKey:@"fbUserId"];
    NSString *zpointFinalURL=[NSString stringWithFormat:CREATE_ZPOINT_SERVICE,WS_ENVIROMENT,self.lat,self.lon,tempZpointName,fbUserId,self.country,self.state,self.city];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             //self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
             //self.greetingContent.text = [greeting objectForKey:@"content"];
             //NSLog(@"Error: %@", [greeting objectForKey:@"location"]);
             if (![tempZpointName isEqual:[greeting objectForKey:@"name"]]){
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"ZiPoint already here"
                                                                 message:[NSString stringWithFormat:@"%@ ZiPoint was created before",[greeting objectForKey:@"name"]]
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
                 [alert show];
             }else{
                 self.zeePointGroupItem = [[ZeePointGroup alloc] init];
                 self.zeePointGroupItem.name=[greeting objectForKey:@"name"];
             }
             [self performSegueWithIdentifier:@"unwindToList" sender:nil];
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 005"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];
         }
     }];
    }
    return true;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    CLLocation *currentLocation = [locations lastObject];
    
    if (currentLocation!=nil){
        self.lat=currentLocation.coordinate.latitude;
        self.lon=currentLocation.coordinate.longitude;
        NSLog(@"%.8f",currentLocation.coordinate.latitude);
        NSLog(@"%.8f",currentLocation.coordinate.longitude);
    }
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error== nil && [placemarks count] > 0){
            CLPlacemark *placemark = [placemarks lastObject];
            tempZpointName=[NSString stringWithFormat:@"%@ %@",placemark.subThoroughfare,placemark.thoroughfare];
            self.country=placemark.country;
            self.state=placemark.administrativeArea;
            self.city=placemark.locality;
            NSLog(@"%@ %@\n%@ %@\n%@\n%@",
                  placemark.subThoroughfare, placemark.thoroughfare,
                  placemark.postalCode, placemark.locality,
                  placemark.administrativeArea,
                  placemark.country);
        }else{
            NSLog(@"%@", error.debugDescription);
        }
    }];
    //[locationManager stopUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    //Your code goes here
}

/*
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"Error: %@", error);
    NSLog(@"Failed to get location! :(");
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
    
    NSLog(@"Location: ∞@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation!=nil){
        NSLog(@"%.8f",currentLocation.coordinate.latitude);
        NSLog(@"%.8f",currentLocation.coordinate.longitude);
    }
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error== nil && [placemarks count] > 0){
            placemark = [placemarks lastObject];
            NSLog(@"%@ %@\n%@ %@\n%@\n%@",
                  placemark.subThoroughfare, placemark.thoroughfare,
                  placemark.postalCode, placemark.locality,
                  placemark.administrativeArea,
                  placemark.country);
        }else{
            NSLog(@"%@", error.debugDescription);
        }
    }];
    
}
 */
@end
