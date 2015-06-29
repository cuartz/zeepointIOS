//
//  LoadImageService.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/28/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZiPointMessage.h"

@class LoadImageService;

@protocol LoadImageServiceDelegatessage

-(void)finishLoadingImage;

@end

@interface LoadImageService : NSObject
@property (nonatomic, assign) id  delegate;

//+ (id)sharedManager;

-(void)imageMessageReceived:(ZiPointMessage*) message;
-(void)loadUserImage:(NSString *) currentUserId faceBookId:(NSString *) currentFbId;
-(NSNumber *)uploadImage:(NSData *)dataImage;

@end
