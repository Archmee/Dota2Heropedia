//
//  DetailViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/5/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "DetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface DetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_vert.jpg", [self.heroIntro objectForKey:@"ename"]]; //大图有矩形_full.png格式和正方形_vert.jpg格式
    [self.imageView sd_setImageWithURL:[NSURL URLWithString: urlStr]];
    
    //self.imageView.clipsToBounds = YES;//已经在storyboard中设置了
    self.textView.text = [self.heroIntro objectForKey:@"bio"];
    self.title = [self.heroIntro objectForKey:@"dname"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
