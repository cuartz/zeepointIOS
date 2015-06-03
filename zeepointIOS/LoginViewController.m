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
//#import "Foundation.h"

@interface LoginViewController ()


@end

@implementation LoginViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    FBSDKLoginButton *loginButton = (FBSDKLoginButton *)[self.view viewWithTag:1];
    loginButton.readPermissions=@[@"public_profile", @"email"];// readPermissions
    //loginButton.setReadPermissions("user_friends");
    //loginButton.setReadPermissions("public_profile");
    //loginButton.setReadPermissions("email");
    //loginButton.setReadPermissions("user_birthday");
    //[self.view addSubview:loginButton];
    // Do any additional setup after loading the view.
    

    
    //loginButton = [[FBSDKLoginButton alloc] init];
    //loginButton.readPermissions = @[@"public_profile", @"email"];
    
    //FBSDKLoginButton *del=[self delete:<#(id)#>];
    
    //loginButton.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated{
    //UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *userId=[prefs objectForKey:@"userId"];
    NSString *fbUserId=[prefs objectForKey:@"fbUserId"];
    NSString *email=[prefs objectForKey:@"email"];
    //[prefs gsetObject:name forKey:@"userId”];
    
    if ([FBSDKAccessToken currentAccessToken] || (userId!=nil && fbUserId!=nil && email!=nil )) {
        NSString *deviceToken=[prefs objectForKey:@"DeviceToken"];
        
        [self saveUserInfo:fbUserId :deviceToken];
    
        
 //       UIViewController *uiViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainMenuView"];//zeePointsView"];
        
  //      [self presentViewController:uiViewController animated:YES completion:nil];
        // User is logged in, do work such as go to next view controller.
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)  loginButton:(FBSDKLoginButton *)loginButton
didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result
                error:(NSError *)error{
    
    
    
    if ([FBSDKAccessToken currentAccessToken]) {
        [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil]
         startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection,
                                      id result, NSError *error) {
             if (error) {
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 002"
                                                                 message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                                delegate:nil
                                                       cancelButtonTitle:@"OK"
                                                       otherButtonTitles: nil];
                 [alert show];
             }else{
                 
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
                          NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                                   options:0
                                                                                     error:NULL];
                          
                          NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                          
                          NSString *usernameR=[greeting objectForKey:@"name"];
                          NSNumber *userIdR=[greeting objectForKey:@"id"];
                          NSString *genderR=[greeting objectForKey:@"gender"];
                          NSString *emailR=[greeting objectForKey:@"email"];
                          
                          [prefs setObject:fbUserId forKey:@"fbUserId"];
                          [prefs setObject:usernameR forKey:@"name"];
                          [prefs setObject:userIdR forKey:@"userId"];
                          [prefs setObject:emailR forKey:@"email"];
                          [prefs setObject:genderR forKey:@"gender"];
                          
                          
                      }else{
                          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 003"
                                                                          message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                                         delegate:nil
                                                                cancelButtonTitle:@"OK"
                                                                otherButtonTitles: nil];
                          [alert show];
                          //[alert rerelease];
                          
                      }
                  }];
                 
             }
         }];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 006"
                                                        message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    
    NSString *fbUserId=[[result token] userID];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSString *deviceToken=[prefs objectForKey:@"DeviceToken"];
    
    [self saveUserInfo:fbUserId :deviceToken];

    
    
    //if ([FBSDKAccessToken currentAccessToken]) {
    //NSString *email=[result dictionaryWithValuesForKeys:@"email"];

    

    //[prefs setObject:fbUserId forKey:@"FBUserId"];
    
    //NSString *userName = [FBuser name];
    //NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", userId];

    

        // User is logged in, do work such as go to next view controller.
   // }
}
UIActivityIndicatorView   *indicator;
- (void)saveUserInfo:(NSString *) fbUserId :(NSString *)deviceToken{
    //
    //CGRect b = self.view.bounds;
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
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
    
      //load NSUserDefaults
    //NSString *fbUserId = userId;  //declare array to be stored in NSUserDefaults
    NSString *zpointFinalURL=[NSString stringWithFormat:LOGIN_USER_SERVICE,WS_ENVIROMENT,fbUserId, deviceToken];
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
             NSDictionary *greeting = [NSJSONSerialization JSONObjectWithData:data
                                                                      options:0
                                                                        error:NULL];
             //self.greetingId.text = [[greeting objectForKey:@"id"] stringValue];
             //self.greetingContent.text = [greeting objectForKey:@"content"];
             //NSLog(@"Error: %@", [greeting objectForKey:@"location"]);
             NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
             NSNumber *userId=[greeting objectForKey:@"id"];
             NSString *host=[greeting objectForKey:@"host"];
             [prefs setObject:fbUserId forKey:@"fbUserId"];
             [prefs setObject:userId forKey:@"userId"];
             [prefs setObject:host forKey:@"host"];
             
             UIStoryboard* storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             UIViewController *uiViewController = [storyboard instantiateViewControllerWithIdentifier:@"mainMenuView"];
             
             [self presentViewController:uiViewController animated:YES completion:nil];
         }
         else{
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Code 001"
                                                             message:@"Problem Occurred, go to www.zipoints.com and report it so we start fixing it!"
                                                            delegate:nil
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles: nil];
             [alert show];
             //[alert rerelease];
             
         }
         [indicator removeFromSuperview];
         indicator = nil;
     }];
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton{
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
