//
//  DetailViewController.m
//  Dota2HeroIntro
//
//  Created by shouzhi on 16/5/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITextView *textView;

@end

@implementation DetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSString *imageEName = [[[self.heroIntro objectForKey:@"ename"] lowercaseString] stringByAppendingString:@"_full.png"];
    self.imageView.image = [UIImage imageNamed: imageEName];
    //self.imageView.clipsToBounds = YES;
    self.textView.text = [self.heroIntro objectForKey:@"bio"];
    self.title = [self.heroIntro objectForKey:@"name"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
