//
//  ZiPointUsersViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/3/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZiPointUsersViewController.h"
#import "ZeePointUser.h"
#import "ZeePointGroup.h"
#import "ZiPointUserTableCell.h"
#import "SWRevealViewController.h"
#import "Constants.h"

@interface ZiPointUsersViewController ()

@property (strong, nonatomic) NSMutableSet *ziPointUsers;
@property (strong, nonatomic) NSArray *sortedZiPointUsers;
@property (strong, nonatomic) NSArray *filteredZiPointUsers;
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@end

@implementation ZiPointUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.ziPointUsers=[[NSMutableSet alloc] init];
    //self.zeePoints=[ZeePointGroup loadInitialData];
    
    self.filteredZiPointUsers=[[NSArray alloc] init];
    //[locationManager startUpdatingLocation];
    
    //self.searchDisplayController.navigationItem.title = @"title";
    
}

-(void)viewDidDisappear:(BOOL)animated{
}

-(void)viewWillAppear:(BOOL)animated{
    NSLog(@"entro a will apear");
    
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_USERS_SERVICE,WS_ENVIROMENT,self.zeePointJoined.zpointId];
    NSURL *url = [NSURL URLWithString:zpointFinalURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             [self.ziPointUsers removeAllObjects];
             [self populateTable:data];
             
             
         }else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 014"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];
         }
     }];
    
}


/* TAL VEZ SEA BUENA IDEA REFRESCAR LA LISTA DE USUARIOS CUANDO LA PERSONA HAGA ESTO
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
        [self getMoreData:[self.ziPoints count]+1];
    }
}


-(void)getMoreData:(NSUInteger)toRow{

    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *userId=[prefs objectForKey:@"userId"];
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_ZPOINTS_SERVICE,WS_ENVIROMENT,self.lat,self.lon,[userId stringValue],toRow];
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
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 008"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];
         }
     }];
}

-(void)viewDidLayoutSubviews{
    
    self.navigationController.navigationBar.translucent = NO;
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        
        self.edgesForExtendedLayout = UIRectEdgeNone;   // iOS 7 specific
    
}*/


-(void)populateTable:(NSData *)data{
    NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    NSArray *zpointUsersArray=[greeting objectForKey:@"users"];
    
    
    for (id zpointUser in zpointUsersArray) {
        ZeePointUser *item = [[ZeePointUser alloc] init];
        
        item.fbId=[zpointUser objectForKey:@"fbId"];
        item.gender = [zpointUser objectForKey:@"gender"];
        item.userId = [zpointUser objectForKey:@"id"];
        //item.range = [zpoint objectForKey:@"name"];
        item.age = [zpointUser objectForKey:@"age"];
        //item.friends = [zpoint objectForKey:@"name"];
        //item.email = [zpointUser objectForKey:@"listeners"];
        item.userName = [zpointUser objectForKey:@"name"];
        //item8.hiddenn=@YES;
        

        [self.ziPointUsers addObject:item];
    }
    
    self.sortedZiPointUsers=[self.ziPointUsers sortedArrayUsingDescriptors:[ZeePointUser getSortDescriptors]];
    
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
        return [self.filteredZiPointUsers count];
    }else{
        return [self.sortedZiPointUsers count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)atableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *simpleTableIdentifier = @"ZiPointUserCell";
    
    ZiPointUserTableCell *ziPointUserCell = [self.tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];

    ZeePointUser *zeePointUser =[[ZeePointUser alloc] init];
    if (atableView == self.searchDisplayController.searchResultsTableView) {
        zeePointUser=[self.filteredZiPointUsers objectAtIndex:indexPath.row];
    }else{
        zeePointUser=[self.sortedZiPointUsers objectAtIndex:indexPath.row];
    }
    
    ziPointUserCell.userNameLabel.text = zeePointUser.userName;
    //ziPointUserCell.zeePointUsersLabel.text =
    //[ZeePointUser getUsersLabelText:zeePoint.users friendsParam:zeePoint.friends listenersParam:zeePoint.listeners];
    
    //zeePointCell.zeePointDistanceLabel.text = [ZeePointGroup getDistanceLabelText:zeePoint.distance];
    //zeePointCell.zeePointDistanceLabel.textColor=[ZeePointGroup getDistanceLabelColor:zeePoint.distance];
    //[zeePointCell.zeePointNameLabel setFont:[ZeePointGroup getTitleFontStyle:zeePoint.friends]];
    //[zeePointCell.zeePointUsersLabel setFont:[ZeePointGroup getUsersFontStyle:zeePoint.friends]];
    //[zeePointCell.zeePointDistanceLabel setFont:[ZeePointGroup getDistanceFontStyle:zeePoint.friends]];
    //zeePointCell.zeePointNameLabel.textColor=[ZeePointGroup getTitleLabelColor:zeePoint.distance];
    
    //zeePointCell.zeePointImage.image = "zeepoint image.png";
    //if (zeePoint.joined) {
    //    zeePointCell.zeePointNameLabel.textColor= [ZeePointGroup getJoinTitleLabelColor];
    //}
    
    return ziPointUserCell;
}
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZeePointUser *zeePointUser =[[ZeePointUser alloc] init];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        zeePointUser=[self.filteredZiPointUsers objectAtIndex:indexPath.row];
    }else{
        zeePointUser=[self.sortedZiPointUsers objectAtIndex:indexPath.row];
    }
    if (zeePointUser.history){
        [self performSegueWithIdentifier:@"showListenerPrivateRoom" sender:self];
    }else{
        [self performSegueWithIdentifier:@"showPrivateRoom" sender:self];
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
    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"userName contains[c] %@", searchText];
    self.filteredZiPointUsers = [self.sortedZiPointUsers filteredArrayUsingPredicate:resultPredicate];
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPrivateRoom"] || [segue.identifier isEqualToString:@"showListenerPrivateRoom"]) {
        //NSIndexPath *indexPath = [self.zeePointJoined indexPathForSelectedRow];
        SWRevealViewController *controller=segue.destinationViewController;
        //NSLog(controller);
        //RecipeDetailViewController *destViewController = segue.destinationViewController;
        
        //ZeePointGroup *zeePoint =[[ZeePointGroup alloc] init];
        if (self.searchDisplayController.active) {
            self.zeePointJoined=[self.filteredZiPointUsers objectAtIndex:[self.tableView indexPathForSelectedRow].row];
        }else{
            self.zeePointJoined=[self.sortedZiPointUsers objectAtIndex:[self.tableView indexPathForSelectedRow].row];
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
        //controller.lat = self.lat;
        //controller.lon = self.lon;
        controller.RoomNavBar.title = self.zeePointJoined.name;
    }
}

@end
