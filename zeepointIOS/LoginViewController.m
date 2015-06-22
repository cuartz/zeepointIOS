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

@interface LoginViewController ()

    @property ZiPointWSService *zipService;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    FBSDKLoginButton *loginButton = (FBSDKLoginButton *)[self.view viewWithTag:1];
    loginButton.readPermissions=@[@"public_profile", @"email"];
    _zipService = [ZiPointWSService sharedManager];
}

-(void)viewDidAppear:(BOOL)animated{
  /*
    NSString *userId=_zipService.getUserId;
    NSString *fbUserId=_zipService.getFbUserId;
    NSString *email=_zipService.getEmail;
    
    if ([FBSDKAccessToken currentAccessToken] || (userId!=nil && fbUserId!=nil && email!=nil )) {
        NSString *deviceToken=_zipService.getDeviceToken;
        
        [self saveUserInfo:fbUserId :deviceToken];
    }*/
    
    
    //ZiPointWSService *zipService = [ZiPointWSService sharedManager];
    
    NSString *userId=_zipService.getUserId;
    NSString *fbUserId=_zipService.getFbUserId;
    NSString *email=_zipService.getEmail;
    
    if ([FBSDKAccessToken currentAccessToken] || (userId!=nil && fbUserId!=nil && email!=nil )){
        
        [self goToMainView];
    }
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
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
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
                          
                          [_zipService setUserName:[response objectForKey:@"name"]];
                          [_zipService setUserId:[[response objectForKey:@"id"] description]];
                          [_zipService setEmail:[response objectForKey:@"email"]];
                          [_zipService setGender:[response objectForKey:@"gender"]];
                          [_zipService setFbUserId:fbUserId];
                          
                          [_zipService saveUserInfo:_zipService.getFbUserId :_zipService.getDeviceToken];
                          
                          
                          
                          
                      }else{
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error Code 002","Error code")
                                                                          message:@"Problem Occurred, you need internet connection"
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
