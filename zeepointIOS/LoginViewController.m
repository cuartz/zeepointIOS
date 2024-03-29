//
//  LoginViewController.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/11/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "LoginViewController.h"
#import <FBSDKCoreKit/FBSDKAccessToken.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ZeePointsViewController.h"
#import "Constants.h"
#import "ZiPointWSService.h"
#import "ZiPointDataService.h"

@interface LoginViewController ()

    @property ZiPointWSService *zipService;
    @property ZiPointDataService *zipDataService;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //_loginButton = [[FBSDKLoginButton alloc] init];
    
    //loginButton.center = self.view.center;
    //[self.view addSubview:loginButton];
    
    //FBSDKLoginButton *loginButton = (FBSDKLoginButton *)[self.view viewWithTag:1];
    
    NSString *userId=_zipDataService.getUserId;
    NSString *fbUserId=_zipDataService.getFbUserId;
    NSString *email=_zipDataService.getEmail;
    
    if ([FBSDKAccessToken currentAccessToken] && (userId!=nil && fbUserId!=nil && email!=nil )){
        
        [self goToMainView];
    }
    
    self.loginButton.readPermissions=@[@"public_profile", @"email"];
    self.loginButton.delegate=self;
    _zipService = [ZiPointWSService sharedManager];
    _zipDataService = [ZiPointDataService sharedManager];
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
  /*
    NSString *userId=_zipService.getUserId;
    NSString *fbUserId=_zipService.getFbUserId;
    NSString *email=_zipService.getEmail;
    
    if ([FBSDKAccessToken currentAccessToken] || (userId!=nil && fbUserId!=nil && email!=nil )) {
        NSString *deviceToken=_zipService.getDeviceToken;
        
        [self saveUserInfo:fbUserId :deviceToken];
    }*/
    
    
    //ZiPointWSService *zipService = [ZiPointWSService sharedManager];
    
   /* */
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)goToMainView {
    UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *uiViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainMenuView"];
    
    [self presentViewController:uiViewController animated:YES completion:nil];
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error{
    
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, email, gender"}]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                      id result, NSError *error) {
             if (error) {
                 /*UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Code 002","Error code")
                                                                 message:NSLocalizedString(@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!","Report message")
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
                 [alert show];*/
             }else{
                 //NSString *fbUserId=[[result token] userID];
                 NSLog( @"### running FB sdk version: %@", [FBSDKSettings sdkVersion] );
                 NSString *fbUserId=[result valueForKeyPath:@"id"];
                 NSString *username=[result valueForKeyPath:@"name"];
                 NSString *gender=[result valueForKeyPath:@"gender"];
                 NSString *email=[result valueForKeyPath:@"email"];
                 
                 NSString *zpointFinalURL=[NSString stringWithFormat:SAVE_USER_INFO,WS_ENVIROMENT,username,fbUserId, gender, email];
                 NSURL *url = [NSURL URLWithString:[zpointFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
                 NSURLRequest *request = [NSURLRequest requestWithURL:url];
                 [NSURLConnection sendAsynchronousRequest:request
                                                    queue:[NSOperationQueue mainQueue]
                                        completionHandler:^(NSURLResponse *response,
                                                            NSData *data, NSError *connectionError)
                  {
                      if (data.length > 0 && connectionError == nil &&
                          [[NSJSONSerialization JSONObjectWithData:data options:0 error:NULL] objectForKey:@"name"]!=nil)
                      {
                          NSDictionary *response = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:NULL];
                          
                          [_zipDataService setUserName:[response objectForKey:@"name"]];
                          [_zipDataService setUserId:[[response objectForKey:@"id"] description]];
                          [_zipDataService setEmail:[response objectForKey:@"email"]];
                          [_zipDataService setGender:[response objectForKey:@"gender"]];
                          [_zipDataService setFbUserId:fbUserId];
                          
                          [_zipService saveUserInfo:_zipDataService.getFbUserId :_zipDataService.getDeviceToken];
                          
                          
                          
                          
                      }else{
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Code 002","Error code")
                                                                          message:@"Problem Occurred, not able to communicate with the server"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles: nil];
                          [alert show];
                          
                      }
                  }];
                 
             }
         }];
        [self goToMainView];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Code 003","Error code")
                                                        message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    
    
    //[self saveUserInfo:fbUserId :_zipService.getDeviceToken];
}



- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

@end
