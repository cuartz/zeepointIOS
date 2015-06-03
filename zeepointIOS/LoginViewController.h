//
//  LoginViewController.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/11/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKLoginKit/FBSDKLoginButton.h>

@interface LoginViewController : UIViewController <FBSDKLoginButtonDelegate>

@property (nonatomic, strong) IBOutlet FBSDKLoginButton *loginButton;
//@property (copy, nonatomic) NSString *deviceID;

@end
