//
//  Constants.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/15/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "Constants.h"

@implementation Constants

NSString *const WS_ENVIROMENT = @"http://localhost:8080";
//NSString *const WS_ENVIROMENT = @"http://www.zeepoint.com";
NSString *const CREATE_ZPOINT_SERVICE = @"%@/mobilews/zeepointgroups/addzpoint?lat=%.8f&lon=%.8f&name=%@&fb_id=%@&country=%@&state=%@&city=%@";
NSString *const GET_ZPOINTS_SERVICE = @"%@/mobilews/zeepointgroups/getzpoints?lat=%.8f&lon=%.8f&user_id=%@&from_row=%d";
NSString *const LOGIN_USER_SERVICE =@"%@/mobilews/users/userlogin?fb_id=%@&device_id=%@";

NSString *const JOIN_ZPOINT_SERVICE =@"%@/mobilews/zeepointgroups/join?id=%@&user_id=%@&lat=%.8f&lon=%.8f";

NSString *const SAVE_USER_INFO =@"%@/mobilews/users/saveuser?name=%@&fb_id=%@&gender=%@&email=%@";
NSString *const FB_USER_PIC =@"http://graph.facebook.com/%@/picture?type=square";
NSString *const GET_PREVIOUS_MSGS =@"%@/mobilews/zeepointgroups/getmessages?id=%@&user_id=%@&last_message=%@";
@end
