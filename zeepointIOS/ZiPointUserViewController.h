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
#import "JSQMessagesViewController.h"


@class ZiPointUserViewController;

@interface ZiPointUserViewController : JSQMessagesViewController <UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

//@property (weak, nonatomic) id<JSQDemoViewControllerDelegate> delegateModal;

//@property (strong, nonatomic) DemoModelData *demoData;

@end

