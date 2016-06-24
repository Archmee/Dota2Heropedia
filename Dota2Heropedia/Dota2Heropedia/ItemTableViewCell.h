//
//  ItemTableViewCell.h
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/24.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *ItemImage;
@property (weak, nonatomic) IBOutlet UILabel *itemName;
@property (weak, nonatomic) IBOutlet UIImageView *costImage;
@property (weak, nonatomic) IBOutlet UILabel *costLabel;

@property (weak, nonatomic) IBOutlet UILabel *qualLable;

@end
