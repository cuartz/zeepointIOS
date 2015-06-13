//
//  ZeePointsViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZeePointsViewController.h"
#import "ZeePointGroup.h"
#import "ZeePointViewController.h"
#import "ZeePointTableViewCell.h"
#import "CreateZeePointViewController.h"
#import "Constants.h"
#import "SWRevealViewController.h"
#import "LoadingView.h"

@interface ZeePointsViewController ()

@property (strong, nonatomic) NSMutableSet *zeePoints;
@property (strong, nonatomic) NSArray *sortedZeePoints;
@property (strong, nonatomic) NSArray *filteredZeePoints;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property double lat;
@property double lon;
@property ZeePointGroup *zeePointJoined;
//@property BOOL *searching;
@end

@implementation ZeePointsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];

    locationManager.delegate = self;

    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0){
        if ([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [locationManager requestWhenInUseAuthorization];
        }
    }
    //[locationManager setDistanceFilter:50];
    
    self.zeePoints=[[NSMutableSet alloc] init];
    //self.zeePoints=[ZeePointGroup loadInitialData];
    
    self.filteredZeePoints=[[NSArray alloc] init];
    //[locationManager startUpdatingLocation];
    
    
    
    
    
   // UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    //[self navigationItem].title = barButton;
    //[activityIndicator startAnimating];
    
    UIView *aiView = [[LoadingView alloc] init];
    //aiView.hidesWhenStopped = NO; //I added this just so I could see it
    self.navigationItem.titleView = aiView;
//[aiView startAnimating];
    
    //self.navigationItem.title=@"ddd";
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [locationManager stopUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated{
    [locationManager startUpdatingLocation];
    //[locationManager stopUpdatingLocation];
    //[locationManager startMonitoringSignificantLocationChanges];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation!=nil){
        self.lat=currentLocation.coordinate.latitude;
        self.lon=currentLocation.coordinate.longitude;
        NSLog(@"Location updated: %.8f",currentLocation.coordinate.latitude);
        //NSLog(@"%.8f",currentLocation.coordinate.longitude);
    }
    //self.zeePoints=[[NSSet alloc] init];
    [self.zeePoints removeAllObjects];
    [self getMoreData:0];
    [locationManager stopUpdatingLocation];
   // [locationManager startMonitoringSignificantLocationChanges];
}
/*
- (void)tableView:(UITableView *)tableView
  willDisplayCell:(UITableViewCell *)cell
forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row>[self.zeePoints count]-2){
        [self getMoreData:[self.sortedZeePoints count]];
        NSLog(@"ultima fila");
        

    }
}
*/
- (void)scrollViewDidEndDragging:(UIScrollView *)aScrollView
                  willDecelerate:(BOOL)decelerate
{
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    
    float reload_distance = 50;
    if(y > h - reload_distance) {
        [self getMoreData:[self.zeePoints count]+1];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    // reset the current position label
    //self.currentPositionLabel.text = @"Current position: ???";
    
    // show the error alert
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error obtaining location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

-(void)getMoreData:(NSUInteger)toRow{
    /*
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
                                          UIActivityIndicatorViewStyleWhite];
    //center the indicator in the view
    [indicator setFrame:self.view.frame];
    //indicator.frame = CGRectMake((b.size.width - 20) / 2, (b.size.height - 20) / 2, 20, 20);
    [indicator.layer setBackgroundColor:[[UIColor colorWithWhite: 0.0 alpha:0.30] CGColor]];
    CGPoint center = self.view.center;
    indicator.center = center;
    [self.view addSubview: indicator];
    //[indicator release];
    [indicator startAnimating];
    */
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *userId=[prefs objectForKey:@"userId"];
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_ZPOINTS_SERVICE,WS_ENVIROMENT,self.lat,self.lon,[userId stringValue],toRow];
    NSURL *url = [NSURL URLWithString:zpointFinalURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [NSURLConnection sendAsynchronousRequest:request
//                                       queue:[NSOperationQueue mainQueue]
//                           completionHandler:^(NSURLResponse *response,
//                                               NSData *data, NSError *connectionError)
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             
             [self populateTable:data];
             
             
             [locationManager stopUpdatingLocation];
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 008"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];
         }
     }];
    //[indicator removeFromSuperview];
    //indicator = nil;
}

-(void)populateTable:(NSData *)data{
    NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    //self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
    //self.greetingContent.text = [greeting objectForKey:@"content"];
    //NSLog(@"Error: %@", [greeting objectForKey:@"location"]);
    NSArray *zpointsArray=[greeting objectForKey:@"zeePointsOut"];
    
    
    
    
    //NSMutableArray *zeePoints=[[NSMutableArray alloc] init];
    
    for (id zpoint in zpointsArray) {
        ZeePointGroup *item = [[ZeePointGroup alloc] init];
        item.zpointId=[zpoint objectForKey:@"id"];
        item.name = [zpoint objectForKey:@"name"];
        item.users = [zpoint objectForKey:@"users"];
        //item.range = [zpoint objectForKey:@"name"];
        item.distance = [zpoint objectForKey:@"distance"];
        //item.friends = [zpoint objectForKey:@"name"];
        item.listeners = [zpoint objectForKey:@"listeners"];
        item.referenceId = [zpoint objectForKey:@"referenceId"];
        //item8.hiddenn=@YES;
        
        item.joined=[[zpoint objectForKey:@"joined"] boolValue];;
        [self.zeePoints addObject:item];
    }
    
    //self.zeePoints=[ZeePointGroup loadInitialData];
    
    self.sortedZeePoints=[self.zeePoints sortedArrayUsingDescriptors:[ZeePointGroup getSortDescriptors]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma Table View Methods

- (NSInteger)tableView:(UITableView *)atableView numberOfRowsInSection:(NSInteger)section
{
    if (atableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredZeePoints count];
    }else{
        return [self.sortedZeePoints count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ZeePointCell";
    
    ZeePointTableViewCell *zeePointCell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    /*
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
    }*/
    ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
    if (atableView == self.searchDisplayController.searchResultsTableView) {
        zeePoint=[self.filteredZeePoints objectAtIndex:indexPath.row];
    }else{
        zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
    }
    
    zeePointCell.zeePointNameLabel.text = zeePoint.name;
    zeePointCell.zeePointUsersLabel.text =
    [ZeePointGroup getUsersLabelText:zeePoint.users friendsParam:zeePoint.friends listenersParam:zeePoint.listeners];
    //[toDoItem.users stringValue];
    zeePointCell.zeePointDistanceLabel.text = [ZeePointGroup getDistanceLabelText:zeePoint.distance];
    zeePointCell.zeePointDistanceLabel.textColor=[ZeePointGroup getDistanceLabelColor:zeePoint.distance];
    //[zeePointCell.zeePointNameLabel setFont:[ZeePointGroup getTitleFontStyle:zeePoint.friends]];
        //[zeePointCell.zeePointUsersLabel setFont:[ZeePointGroup getUsersFontStyle:zeePoint.friends]];
        //[zeePointCell.zeePointDistanceLabel setFont:[ZeePointGroup getDistanceFontStyle:zeePoint.friends]];
    zeePointCell.zeePointNameLabel.textColor=[ZeePointGroup getTitleLabelColor:zeePoint.distance];
    
    //zeePointCell.zeePointImage.image = "zeepoint image.png";
    if (zeePoint.joined) {
        zeePointCell.zeePointNameLabel.textColor= [ZeePointGroup getJoinTitleLabelColor];
    }
    
    return zeePointCell;
}
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        zeePoint=[self.filteredZeePoints objectAtIndex:indexPath.row];
    }else{
        zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
    }
    if ([zeePoint.distance intValue]>100){
        [self performSegueWithIdentifier:@"showListenerRoom" sender:self];
    }else{
        [self performSegueWithIdentifier:@"showRoom" sender:self];
    }
}

/*
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //[atableView deselectRowAtIndexPath:indexPath animated:NO];
    ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        zeePoint=[self.filteredZeePoints objectAtIndex:indexPath.row];
    }else{
        zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
    }
    //zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
    
    if (self.zeePointJoined!=nil){
        self.zeePointJoined.joined=NO;
    }
    //zeePoint.joined=YES;
    self.zeePointJoined=zeePoint;
    //[self.tableView reloadData];
    //[atableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId=[prefs objectForKey:@"userId"];
    NSString *zpointFinalURL=[NSString stringWithFormat:JOIN_ZPOINT_SERVICE,WS_ENVIROMENT,zeePoint.zpointId,userId,self.lat,self.lon];
    NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             //[self populateTable:data];
         }
     }];
    
    //tappedItem.joined = !tappedItem.joined;
    
    //[atableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    
    
}*/


#pragma Search Methods

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[c] %@", searchText];
    self.filteredZeePoints = [self.sortedZeePoints filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}



- (IBAction)unwindToList:(UIStoryboardSegue *)segue {
    /*
    CreateZeePointViewController *source = [segue sourceViewController];
    ZeePointGroup *item = source.zeePointGroupItem;
    if (item != nil) {
        [self.zeePoints addObject:item];
        self.sortedZeePoints=[self.zeePoints sortedArrayUsingDescriptors:[ZeePointGroup getSortDescriptors]];
        [self.tableView reloadData];
    }*/

    
}
/*

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showZeePointRoom"]) {
 //       NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
 //       ZeePointViewController *zeePointViewController = [[segue.destinationViewController viewControllers] objectAtIndex: 0];
        
 //       ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
 //       if (tableView == self.searchDisplayController.searchResultsTableView) {
 //           zeePoint=[self.filteredZeePoints objectAtIndex:indexPath.row];
 //       }else{
 //           zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
 //       }
 //       zeePointViewController.zeePoint = zeePoint;
    }
    
}
 */
#pragma mark - CoreLocation actions

- (void)startUpdatingCurrentLocation
{
    NSLog(@"startUpdatingCurrentLocation");
    
    // if location services are restricted do nothing
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied ||
        [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted) {
        return;
    }
    
    // if locationManager does not currently exist, create it
    if (!locationManager) {
        locationManager = [[CLLocationManager alloc] init];
        // set its delegate to self
        locationManager.delegate = self;
        // use the accuracy best suite for navigation
        locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    }
    
    // start updating the location
    [locationManager startUpdatingLocation];
}

- (void)stopUpdatingCurrentLocation
{
    [locationManager stopUpdatingLocation];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRoom"] || [segue.identifier isEqualToString:@"showListenerRoom"]) {
        //NSIndexPath *indexPath = [self.zeePointJoined indexPathForSelectedRow];
        SWRevealViewController *controller=segue.destinationViewController;
        //NSLog(controller);
        //RecipeDetailViewController *destViewController = segue.destinationViewController;
        
        //ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
        if (self.searchDisplayController.active) {
            self.zeePointJoined=[self.filteredZeePoints objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }else{
            self.zeePointJoined=[self.sortedZeePoints objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
        //zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
        
        if (self.zeePointJoined!=nil){
            self.zeePointJoined.joined=NO;
        }
        //zeePoint.joined=YES;
        //self.zeePointJoined=zeePoint;
        //[self.tableView reloadData];
        //[atableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        
        
        
        controller.zeePointJoined = self.zeePointJoined;
        controller.lat = self.lat;
        controller.lon = self.lon;
        //controller.RoomNavBar.title = self.zeePointJoined.name;
    }
}

@end
