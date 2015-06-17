//
//  ZeePointTableViewCell.h
//  ZeePoint
//
//  Created by Carlos Bayona on 3/30/15.
//  Copyright (c) 2015 systematis. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZeePointTableViewCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *zeePointUsersLabel;
@property (strong, nonatomic) IBOutlet UILabel *zeePointDistanceLabel;
@property (strong, nonatomic) IBOutlet UIImageView *zeePointImage;
@property (strong, nonatomic) IBOutlet UILabel *zeePointNameLabel;
@end
