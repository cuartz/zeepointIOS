//
//  ZiPointUsersViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/3/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "ZiPointUsersViewController.h"
#import "ZiPointUserViewController.h"
#import "ZeePointUser.h"
#import "ZeePointGroup.h"
#import "ZiPointUserTableCell.h"
#import "SWRevealViewController.h"
#import "Constants.h"
#import "ZiPointWSService.h"
#import "ZiPointDataService.h"
#import "UserNavigationController.h"

@interface ZiPointUsersViewController ()

@property (strong, nonatomic) NSArray *sortedZiPointUsers;
@property (strong, nonatomic) NSArray *filteredZiPointUsers;
@property (nonatomic, strong) IBOutlet UITableView *tableView;

@property ZiPointWSService *zipService;

@property ZiPointDataService *zipDataService;
@end

@implementation ZiPointUsersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.filteredZiPointUsers=[[NSArray alloc] init];
    _zipService = [ZiPointWSService sharedManager];
    _zipDataService = [ZiPointDataService sharedManager];
    self.sortedZiPointUsers=[_zipDataService.zeePointUsers sortedArrayUsingDescriptors:[ZeePointUser getSortDescriptors]];
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"disapear");
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //NSLog(@"entro a will apear");
    
    NSString *zpointFinalURL=[NSString stringWithFormat:GET_USERS_SERVICE,WS_ENVIROMENT,_zipService.getZiPoint.zpointId];
    NSURL *url = [NSURL URLWithString:zpointFinalURL];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         if (data.length > 0 && connectionError == nil)
         {
             [_zipDataService.zeePointUsers removeAllObjects];
             [self populateTable:data];
             
             
         }else{
             /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 014"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];*/
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
    
}*/


-(void)populateTable:(NSData *)data{
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:NULL];
    
    _zipDataService.zeePointUsers=[_zipService createZipointUsers:dict];
    
    self.sortedZiPointUsers=[_zipDataService.zeePointUsers sortedArrayUsingDescriptors:[ZeePointUser getSortDescriptors]];
    
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
    //ziPointUserCell.userImageView.layer.cornerRadius=23;
    //ziPointUserCell.userImageView.layer.borderWidth=2.0;
    //ziPointUserCell.userImageView.layer.masksToBounds = YES;
    ziPointUserCell.userImageView.image=[UIImage imageWithData:[_zipDataService.images objectForKey:[zeePointUser.userId description]]];//zeePointUser.userImage.avatarImage;//[_zipService.images objectForKey:zeePointUser.u];
    ziPointUserCell.titleLabel.text=zeePointUser.title;

    return ziPointUserCell;
}
- (void)tableView:(UITableView *)atableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    /*
    ZiPointUserViewController *stubController = [[ZiPointUserViewController alloc] init];
    stubController.view.backgroundColor = [UIColor whiteColor];
    [self.revealViewController.navigationController pushViewController:stubController animated:YES];
    */
    
    //ZiPointUserViewController *mapViewController = [[ZiPointUserViewController alloc] init];
    //UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    //UserNavigationController *navigationController = [[UserNavigationController alloc] initWithRootViewController:mapViewController];
    
    //[self.revealViewController pushFrontViewController:navigationController animated:YES];
    
    
    [self.revealViewController revealToggleAnimated:YES];
    [self.revealViewController.frontViewController.childViewControllers[0] performSegueWithIdentifier:@"privateRoomSegue" sender:self];
    
    //[self.parentViewController.navigationController  performSegueWithIdentifier:@"privateRoomSegue" sender:self];//popToRootViewControllerAnimated:NO];
    //[[self.revealViewController.frontViewController.childViewControllers[0] navigationController] popToRootViewControllerAnimated:NO];//:@"privateRoomSegue" sender:self];
    
    
    //[self.revealViewController revealToggleAnimated:NO];
    //[self.revealViewController performSelector:@selector( rightRevealToggle: )];
    //[self.revealViewController.frontViewController.childViewControllers[0] performSelector:@selector( rightRevealToggle: )];

    //[self.revealViewController.childViewControllers[0].frontViewController.navigationController performSegueWithIdentifier:@"privateRoomSegue" sender:self];
    
    //[self.revealViewController.childViewControllers[0] childViewControllers[1]] performSegueWithIdentifier:@"privateRoomSegue" sender:self];
    
    /*
    ZeePointUser *zeePointUser =[[ZeePointUser alloc] init];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        zeePointUser=[self.filteredZiPointUsers objectAtIndex:indexPath.row];
    }else{
        zeePointUser=[self.sortedZiPointUsers objectAtIndex:indexPath.row];
    }*/
    /*if (zeePointUser.history){
        [self performSegueWithIdentifier:@"showListenerPrivateRoom" sender:self];
    }else{
        [self performSegueWithIdentifier:@"showPrivateRoom" sender:self];
    }*/
}

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
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    ZeePointUser *zeePointUser =[[ZeePointUser alloc] init];
    if (self.tableView == self.searchDisplayController.searchResultsTableView) {
        zeePointUser=[self.filteredZiPointUsers objectAtIndex:indexPath.row];
    }else{
        zeePointUser=[self.sortedZiPointUsers objectAtIndex:indexPath.row];
    }
    UINavigationController *destViewController = (UINavigationController*)segue.destinationViewController;
    
    //ZiPointUserViewController *mapViewController = [[ZiPointUserViewController alloc] init];
   // UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:mapViewController];
    
    //[self.revealViewController pushFrontViewController:navigationController animated:YES];
    
    
    destViewController.title = zeePointUser.userName;// capitalizedString];
    //[destViewController setNavigationBarHidden: NO animated:NO];
    
    
    
    //self.revealViewController;
    // Set the photo if it navigates to the PhotoView
  /*  if ([segue.identifier isEqualToString:@"showPhoto"]) {
        UINavigationController *navController = segue.destinationViewController;
        PhotoViewController *photoController = [navController childViewControllers].firstObject;
        NSString *photoFilename = [NSString stringWithFormat:@"%@_photo", [menuItems objectAtIndex:indexPath.row]];
        photoController.photoFilename = photoFilename;
    }*/
}

    
    /*
    if ([segue.identifier isEqualToString:@"showPrivateRoom"] || [segue.identifier isEqualToString:@"showListenerPrivateRoom"]) {
        //SWRevealViewController *controller=segue.destinationViewController;
        if (self.searchDisplayController.active) {
            [_zipService setZiPoint:[self.filteredZiPointUsers objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        }else{
            [_zipService setZiPoint:[self.sortedZiPointUsers objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
        }
        
        if (_zipService.zeePoint!=nil){
            _zipService.zeePoint.joined=NO;
        }
    }
}*/

@end
