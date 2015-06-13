//
//  LoadingView.m
//  zeepointIOS
//
//  Created by Carlos Bayona on 6/13/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import "LoadingView.h"

@interface LoadingView ()

//@property UIActivityIndicatorView* activityIndicator;

@end

@implementation LoadingView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code
        [self configureView];
    }
    return self;
}

-(void)configureView{
    UIActivityIndicatorView *activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityIndicatorView.frame = CGRectMake(0, 0, 22, 22);
    activityIndicatorView.color = [UIColor blackColor];
    [activityIndicatorView startAnimating];
    
    UILabel *titleLabel = [UILabel new];
    titleLabel.text = @"Connecting";
    titleLabel.font = [UIFont boldSystemFontOfSize:14];
    
    CGSize fittingSize = [titleLabel sizeThatFits:CGSizeMake(200.0f, activityIndicatorView.frame.size.height)];
    titleLabel.frame = CGRectMake(activityIndicatorView.frame.origin.x + activityIndicatorView.frame.size.width + 8,
                                  activityIndicatorView.frame.origin.y+3,
                                  fittingSize.width,
                                  fittingSize.height);
    
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(-(activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width)/2,
                                                                 -(activityIndicatorView.frame.size.height)/2,
                                                                 activityIndicatorView.frame.size.width + 8 + titleLabel.frame.size.width,
                                                                 activityIndicatorView.frame.size.height)];
    [titleView addSubview:activityIndicatorView];
    [titleView addSubview:titleLabel];
    
    [self addSubview:titleView];
/*
    self.backgroundColor = [UIColor clearColor];
    
    
    
     UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    //activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    //UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    //[self navigationItem].title = barButton;
    //[activityIndicator startAnimating];
    
    
    //UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
   // activityIndicator.frame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height );
   // activityIndicator.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    //activityIndicator.backgroundColor = [UIColor clearColor];
    
    [self addSubview:activityIndicator];
    
    //CGFloat labelX = activityIndicator.bounds.size.width + 2;
    
    UILabel* label = [[UILabel alloc] init];//]WithFrame:CGRectMake(labelX, 0.0f, self.bounds.size.width - (labelX + 2), self.frame.size.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    label.font = [UIFont boldSystemFontOfSize:12.0f];
    label.numberOfLines = 1;
    
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"Loading..";
    
    [self addSubview:label];
    [activityIndicator startAnimating];*/
}

-(void)startAnimating{
    //[self.activityIndicator startAnimating];
}

-(void)stopAnimating{
    //[self.activityIndicator stopAnimating];
}
@end
