//
//  Constants.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/15/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "Constants.h"

@implementation Constants

//NSString *const IP = @"localhost:8080";
//NSString *const WS_ENVIROMENT = @"http://localhost:8080";
NSString *const IP = @"52.25.157.20";
NSString *const WS_ENVIROMENT = @"http://52.25.157.20";
NSString *const WS = @"ws://%@/chat/websocket";

NSString *const CREATE_ZPOINT_SERVICE = @"%@/mobilews/zeepointgroups/addzpoint?lat=%.8f&lon=%.8f&name=%@&fb_id=%@&country=%@&state=%@&city=%@";
NSString *const GET_ZPOINTS_SERVICE = @"%@/mobilews/zeepointgroups/getzpoints?lat=%.8f&lon=%.8f&user_id=%@&from_row=%d";
NSString *const GET_FAV_ZPOINTS_SERVICE = @"%@/mobilews/zeepointgroups/getfavoritezpoints?lat=%.8f&lon=%.8f&user_id=%@";
NSString *const LOGIN_USER_SERVICE =@"%@/mobilews/users/userlogin?fb_id=%@&device_id=%@";

NSString *const JOIN_ZPOINT_SERVICE =@"%@/mobilews/zeepointgroups/join?id=%@&user_id=%@&lat=%.8f&lon=%.8f";
NSString *const EXIT_ZPOINT_SERVICE =@"%@/mobilews/zeepointgroups/exit?id=%@&user_id=%@";

NSString *const SAVE_USER_INFO =@"%@/mobilews/users/saveuser?name=%@&fb_id=%@&gender=%@&email=%@";
NSString *const FB_USER_PIC =@"http://graph.facebook.com/%@/picture?type=square";
NSString *const GET_PREVIOUS_MSGS =@"%@/mobilews/zeepointgroups/getmessages?id=%@&user_id=%@&last_message=%d";
NSString *const GET_USERS_SERVICE = @"%@/mobilews/zeepointgroups/getusers?id=%@";

NSString *const CLOUDINARY_SERVICE = @"cloudinary://388324436659163:9i593lnMS89RoF9lp6iAcOc1qCA@zipoints";

NSString *const PHOTO_MESSAGE = @"1";

NSString *const TEXT_MESSAGE = @"0";

NSString *const STOMP_DESTINATION = @"/app/chat/%@";

@end
