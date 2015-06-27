//
//  LeftToRightSegue.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/3/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "LeftToRightSegue.h"

@implementation LeftToRightSegue
/*
-(void)perform{
    UIViewController *src = (UIViewController *) self.sourceViewController;
    [UIView transitionWithView:src
                      duration:2.0
                       options:UIViewAnimationOptionTransitionFlipFromRight +
     UIViewAnimationOptionShowHideTransitionViews
                    animations:^{}
                    completion:nil];  

}
*/


-(void)perform {
    
    __block UIViewController *sourceViewController = (UIViewController*)[self sourceViewController];
    __block UIViewController *destinationController = (UIViewController*)[self destinationViewController];
    
    CATransition* transition = [CATransition animation];
    transition.duration = .25;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionPush; //kCATransitionMoveIn; //, kCATransitionPush, kCATransitionReveal, kCATransitionFade
    transition.subtype = kCATransitionFromLeft; //kCATransitionFromLeft, kCATransitionFromRight, kCATransitionFromTop, kCATransitionFromBottom
    
    
    
    [sourceViewController.navigationController.view.layer addAnimation:transition
                                                                forKey:kCATransition];
    
    [sourceViewController.navigationController pushViewController:destinationController animated:NO];
    
    
}
@end
