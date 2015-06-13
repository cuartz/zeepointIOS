//
//  ZeePointViewController.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 4/4/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZeePointGroup.h"
#import "JSQMessages.h"

#import "DemoModelData.h"
#import "NSUserDefaults+DemoSettings.h"
//#import <WebsocketStompKit/WebsocketStompKit.h>
#import "JSQMessagesViewController.h"


@class ZeePointViewController;

@protocol JSQDemoViewControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ZeePointViewController *)vc;

@end

@interface ZeePointViewController : JSQMessagesViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//@property (nonatomic, strong) IBOutlet UILabel *zeePointNameLabel;


@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

@property (strong, nonatomic) DemoModelData *demoData;

//@property (nonatomic, strong) STOMPClient *client;

//- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

//- (void)closePressed:(UIBarButtonItem *)sender;

@end
