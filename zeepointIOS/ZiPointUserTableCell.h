//
//  ZiPointUsersTableCell.h
//  zeepointIOS
//
//  Created by Carlos Bayona on 5/31/15.
//  Copyright (c) 2015 zeepoint. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZiPointUserTableCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;

@end
