//
//  LoadImageService.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/28/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "LoadImageService.h"
#import "ZiPointDataService.h"
#import "Constants.h"
#import "Cloudinary.h"
@interface LoadImageService () <CLUploaderDelegate>

@property (nonatomic, strong) ZiPointDataService *dataService;

@property CLCloudinary *cloudinary;
@property CLUploader* uploader;
//-(void)subscribeZip;

@end

@implementation LoadImageService

@synthesize delegate;
/*
+ (id)sharedManager {
    static LoadImageService *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}*/

- (id)init {
    //if (self = [super init]) {
        
        self.dataService=[ZiPointDataService sharedManager];
        
        self.cloudinary = [[CLCloudinary alloc] initWithUrl: CLOUDINARY_SERVICE];
        
         self.uploader= [[CLUploader alloc] init:self.cloudinary delegate:self];
        
    //}
    return self;
}

-(void)uploadImage:(NSData *)dataImage randomNumber:(NSNumber *)randomPublicId{
    
    CLTransformation *transformation = [CLTransformation transformation];
    [transformation setWidthWithInt: 210];
    [transformation setHeightWithInt: 150];
    [transformation setCrop: @"fill"];
    
    [self.uploader upload:dataImage options:@{@"resource_type": @"auto",@"transformation": transformation,@"public_id": randomPublicId}];

}

- (void) uploaderSuccess:(NSDictionary*)result context:(id)context {
    
    
    NSString* fileName = [result valueForKey:@"public_id"];
    NSString* urlMessage = [result valueForKey:@"url"];
    
    NSNumber *myMsgid = @((NSUInteger)self.dataService.messages.count);
    
    NSURL *imageURL = [NSURL URLWithString:[urlMessage stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    [self loadImageAsync:imageURL imageKey:urlMessage isImageForAmessage:true secondImageKey:fileName];
    [delegate finishUploadingImage:urlMessage messageId:myMsgid messageType:PHOTO_MESSAGE];
}

- (void) uploaderError:(NSString *)result code:(NSInteger)code context:(id)context {
    NSLog(@"Upload error: %@, %ld", result, (long)code);
}

- (void) uploaderProgress:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite context:(id)context {
    NSLog(@"Upload progress: %ld/%ld (+%ld)", (long)totalBytesWritten, (long)totalBytesExpectedToWrite, (long)bytesWritten);
}

-(void)imageMessageReceived:(ZiPointMessage*) message{
    
    if ([_dataService.images objectForKey:message.message]==nil){
        NSString *picFinalURL=message.message;
        NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        
        [self loadImageAsync:imageURL imageKey:message.message isImageForAmessage:true secondImageKey:nil];
        
    }else{
        for (JSQMessage *msg in _dataService.messages){
            if ([msg isMediaMessage] && [_dataService.images objectForKey:[msg text]] && !msg.received){
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:[_dataService.images objectForKey:[msg text]]]];
                [msg setMedia:photoItem];
                msg.received=true;
            }
        }
        [delegate finishLoadingImage];
    }
}

-(void)loadUserImage:(NSString *) currentUserId faceBookId:(NSString *) currentFbId{
    if ([_dataService.images objectForKey:[currentUserId description]]==nil){
        NSString *picFinalURL=[NSString stringWithFormat:FB_USER_PIC,currentFbId];
        NSURL *imageURL = [NSURL URLWithString:[picFinalURL stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
        [self loadImageAsync:imageURL imageKey:[currentUserId description] isImageForAmessage:false secondImageKey:nil];
        
    }
}

-(void)imageLoaded:(NSData *)imageData messageKey:(NSString *)key isImageForMessage:(bool)isMessage{
    if (isMessage){
        for (JSQMessage *msg in _dataService.messages){
            if ([msg isMediaMessage] && [_dataService.images objectForKey:key] && [[msg text] isEqualToString:key] && !msg.received){
                
                JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageWithData:imageData]];
                if ([msg.senderId isEqual:_dataService.getUserId]){
                    [photoItem setAppliesMediaViewMaskAsOutgoing:YES];
                }else{
                    [photoItem setAppliesMediaViewMaskAsOutgoing:NO];
                }
                
                [msg setMedia:photoItem];
                msg.received=true;
                [delegate finishLoadingImage];
            }
        }
    }else{
        //is avatar
        [_dataService.avatars setObject:[JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData]
                                                                                   diameter:kJSQMessagesCollectionViewAvatarSizeDefault] forKey:key];
        [delegate finishLoadingImage];
    }
    
}

-(NSData *)loadImageAsync:(NSURL *)imageURL imageKey:(NSString *)key isImageForAmessage:(bool) isMessage secondImageKey:(NSString *)secKey{
    __block NSData *imageData;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        @synchronized(key){
            if (![_dataService.images objectForKey:key]){
                imageData = [NSData dataWithContentsOfURL:imageURL];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (imageData){
                        [_dataService.images setObject:imageData forKey:key];
                        if (secKey){
                            [_dataService.images setObject:imageData forKey:secKey];
                            [self imageLoaded:imageData messageKey:secKey isImageForMessage:isMessage];
                        }
                        [self imageLoaded:imageData messageKey:key isImageForMessage:isMessage];
                    }
                });
            }
        }
    });
    return imageData;
}

@end
