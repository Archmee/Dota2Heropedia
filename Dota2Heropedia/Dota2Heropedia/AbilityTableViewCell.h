//
//  AbilityTableViewCell.h
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/1.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AbilityTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *introLabel;
@end
