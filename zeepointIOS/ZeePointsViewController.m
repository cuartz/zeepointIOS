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
#import "ZiPointWSService.h"

@interface ZeePointsViewController ()


@property (strong, nonatomic) NSArray *sortedZeePoints;
@property (strong, nonatomic) NSArray *filteredZeePoints;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property ZiPointWSService *zipService;
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
    
    //self.zeePoints=[[NSMutableSet alloc] init];
    
    self.filteredZeePoints=[[NSArray alloc] init];
    
    _zipService = [ZiPointWSService sharedManager];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [locationManager stopUpdatingLocation];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [locationManager startUpdatingLocation];
    //[self.navigationController setNavigationBarHidden:NO animated:animated];
    //[self.tableView reloadData];
}


- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    
    CLLocation *currentLocation = [locations lastObject];
    if (currentLocation!=nil){
        _zipService.lat=currentLocation.coordinate.latitude;
        _zipService.lon=currentLocation.coordinate.longitude;
    }
    //[self.zeePoints removeAllObjects];
    [self getMoreData:0];
    //[locationManager stopUpdatingLocation];
}

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
        [locationManager startUpdatingLocation];
        [self getMoreData:[_zipService.locationZiPoints count]+1];
    }
}

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] init];
    alert.title = @"Error obtaining location";
    alert.message = [error localizedDescription];
    [alert addButtonWithTitle:@"OK"];
    [alert show];
}

-(void)getMoreData:(NSUInteger)toRow{

    NSString *zpointFinalURL=[NSString stringWithFormat:GET_ZPOINTS_SERVICE,WS_ENVIROMENT,_zipService.lat,_zipService.lon,_zipService.getUserId,toRow];
    NSURL *url = [NSURL URLWithString:zpointFinalURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
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
             /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 008"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];*/
         }
     }];
}

-(void)populateTable:(NSData *)data{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    NSMutableSet *zips=[_zipService createZipointGroups:dict];
    for(ZeePointGroup *currentZip in zips){
       // ZeePointGroup *updatedZip=[_zipService.locationZiPoints member:currentZip];
        if ([_zipService.locationZiPoints member:currentZip]){
         //   updatedZip.distance=currentZip.distance;
            [_zipService.locationZiPoints removeObject:currentZip];
        }
            //else{
            [_zipService.locationZiPoints addObject:currentZip];
        //}
    }

    //[self.zeePoints adaddObjects:[_zipService createZipointGroups:dict]];//[greeting objectForKey:@"zeePointsOut"];
 
    self.sortedZeePoints=[_zipService.locationZiPoints sortedArrayUsingDescriptors:[ZeePointGroup getSortDescriptors]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

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

    ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
    if (atableView == self.searchDisplayController.searchResultsTableView) {
        zeePoint=[self.filteredZeePoints objectAtIndex:indexPath.row];
    }else{
        zeePoint=[self.sortedZeePoints objectAtIndex:indexPath.row];
    }
    
    zeePointCell.zeePointNameLabel.text = zeePoint.name;
    zeePointCell.zeePointUsersLabel.text =
    [ZeePointGroup getUsersLabelText:zeePoint.users friendsParam:zeePoint.friends listenersParam:zeePoint.listeners];

    zeePointCell.zeePointDistanceLabel.text = [ZeePointGroup getDistanceLabelText:zeePoint.distance alwaysDisplayDistance:false];
    zeePointCell.zeePointDistanceLabel.textColor=[ZeePointGroup getDistanceLabelColor:zeePoint.distance];
    zeePointCell.zeePointNameLabel.textColor=[ZeePointGroup getTitleLabelColor:zeePoint.distance senderId:_zipService.getUserId ownerId:zeePoint.ownerId];
    
    if ([zeePoint.referenceId isEqualToString:_zipService.getZiPoint.referenceId]){//zeePoint.joined ) {
        zeePointCell.zeePointNameLabel.textColor= [ZeePointGroup getJoinTitleLabelColor];
    }
    
    return zeePointCell;
}
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        [_zipService setZiPoint:[self.filteredZeePoints objectAtIndex:indexPath.row]];
    }else{
        [_zipService setZiPoint:[self.sortedZeePoints objectAtIndex:indexPath.row]];
    }
    //if ([zeePoint.distance intValue]>100 && !([zeePoint.ownerId isEqualToString:_zipService.getUserId])){
    //    [self performSegueWithIdentifier:@"showListenerRoom" sender:self];
    //}else{
    //    [self performSegueWithIdentifier:@"showRoom" sender:self];
    //}
    self.tabBarController.selectedIndex = 2;
}

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
}

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

/*
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showRoom"] || [segue.identifier isEqualToString:@"showListenerRoom"]) {

        if (self.searchDisplayController.active) {
            _zipService.zeePoint=[self.filteredZeePoints objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }else{
            _zipService.zeePoint=[self.sortedZeePoints objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }
        
        if (_zipService.zeePoint!=nil){
            _zipService.zeePoint.joined=NO;
        }
    }
}*/

@end
