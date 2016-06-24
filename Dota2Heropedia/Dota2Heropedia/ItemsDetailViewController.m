//
//  ItemsDetailViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/24.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "ItemsDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DataMode.h"

#define mainWidth self.view.frame.size.width
#define mainHeight self.viewe.frame.size.height

@interface ItemsDetailViewController ()
{
    int _topHeight; //该变量用于在新建一个元素时获取上面一个元素到顶部的高度
}
@end

@implementation ItemsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _topHeight = 0;

    self.title = [self.itemDetail objectForKey:@"dname"];
    self.view.backgroundColor = [UIColor colorWithRed:240/255 green:240/255 blue:240/255 alpha:1]; //这个效果不大，应为会被后面的背景遮住
    
    [self setHeadInfo];
    [self setDetailInfo];
    [(UIScrollView *)self.view setContentSize:CGSizeMake(mainWidth, _topHeight+10) ]; //如果设置了self.view为UIScrollView，那么这里就要设置宽高才能做到滚动的效果
}

-(void)setHeadInfo {
    //item图像
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, 10, 85, 64)];
    [headImage sd_setImageWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/items/%@_lg.png", self.itemName]] ];
    [self.view addSubview: headImage];
    _topHeight += 10+headImage.frame.size.height;
    
    //itemName label
    UILabel *itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+headImage.frame.size.width+10, 8, 200, 20)];
    itemLabel.text = [self.itemDetail objectForKey:@"dname"];
    itemLabel.textColor = [UIColor colorWithRed:30/255 green:144/255 blue:255/255 alpha:1];
    itemLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:17];
    //itemLabel.lineBreakMode = NSLineBreakByClipping;
    itemLabel.numberOfLines = 0;
    [itemLabel sizeToFit];
    [self.view addSubview:itemLabel];
    
    //金钱消耗图标
    UIImageView *costImage = [[UIImageView alloc] initWithFrame:CGRectMake(8+headImage.frame.size.width+10, 8+itemLabel.frame.size.height+20, 25, 20)];
    [costImage sd_setImageWithURL: [NSURL URLWithString:@"http://cdn.dota2.com/apps/dota2/images/tooltips/gold.png"] ];
    [self.view addSubview:costImage];
    
    //金钱消耗数字label
    itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+headImage.frame.size.width+10+costImage.frame.size.width+10, 8+itemLabel.frame.size.height+20, 100, 40)];
    itemLabel.text = [NSString stringWithFormat:@"%@", [self.itemDetail objectForKey:@"cost"]];
    itemLabel.textColor = [UIColor orangeColor];
    itemLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    itemLabel.numberOfLines = 0;
    [itemLabel sizeToFit];
    [self.view addSubview:itemLabel];
    
    //物品类型的label
    itemLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainWidth-100-8, 8, 100, headImage.frame.size.height)];
    itemLabel.text = [[[DataMode shareModel] itemQual] objectForKey: [self.itemDetail objectForKey:@"qual"] ];
    itemLabel.textColor = [UIColor grayColor];
    itemLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    itemLabel.textAlignment = NSTextAlignmentRight;
    itemLabel.numberOfLines = 0;
    //[itemLabel sizeToFit]; //会自动变小，而导致默认的垂直对齐，水平对齐样式使用不了
    [self.view addSubview:itemLabel];

}

-(void)setDetailInfo {
    //desc label
    NSString *descStr = [self.itemDetail objectForKey:@"desc"];
    if (![descStr isEqualToString:@""]) {
        //这里是为了去掉多余的<br />标签
        NSMutableArray *arr = [[descStr componentsSeparatedByString:@"<br />"] mutableCopy];
        for (int i=0; i < arr.count; i++) {
            NSString *cur = arr[i];
            arr[i] = [cur stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]]; //去掉前导和尾部换行符
        }
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, _topHeight+20, mainWidth-16, 100)];
        descLabel.text = [arr componentsJoinedByString:@"\n"];//将数组用 \n 连接起来
        descLabel.textColor = [UIColor whiteColor];
        descLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        descLabel.numberOfLines = 0;
        [descLabel sizeToFit];
        [self.view addSubview:descLabel];
        _topHeight += 20+descLabel.frame.size.height;
        
    }
    
    //notes label
    NSString *notes = [self.itemDetail objectForKey:@"notes"];
    if (![notes isEqualToString:@""]) {
        UILabel *notesLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, _topHeight+20, mainWidth-16, 100)];
        NSArray *arr = [[self.itemDetail objectForKey:@"notes"] componentsSeparatedByString:@"<br />"];
        notesLabel.text = [arr componentsJoinedByString:@"\n"];//将数组用 \n 连接起来
        notesLabel.textColor = [UIColor greenColor];
        notesLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16];
        notesLabel.numberOfLines = 0;
        [notesLabel sizeToFit];
        [self.view addSubview:notesLabel];
        _topHeight += 20+notesLabel.frame.size.height;
    }
    
    //attribute label
    NSString *attriStr = [self.itemDetail objectForKey:@"attrib"];
    if (![attriStr isEqualToString:@""]) {
        NSArray *arr = [attriStr componentsSeparatedByString:@"<br />"];
        NSString *filteredStr = [self filterHtml:arr];
        
        UILabel *attriLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+20, _topHeight+20, mainWidth-16-40, 100)];
        attriLabel.text = filteredStr; //将数组用 \n 连接起来
        attriLabel.textColor = [UIColor yellowColor];
        attriLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16];
        attriLabel.numberOfLines = 0;
        [attriLabel sizeToFit];
        [self.view addSubview:attriLabel];
        _topHeight += 20+attriLabel.frame.size.height;
    }
    
    //mc 和 cd 的小图标和数值
    id cd = [self.itemDetail objectForKey:@"cd"];
    id mc = [self.itemDetail objectForKey:@"mc"];
    
    if (![cd isEqualToNumber:@0]) { // 0 = FALSE = NO
        UIImageView *cdImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, _topHeight+20, 22, 22)];
        [cdImage sd_setImageWithURL:[NSURL URLWithString:@"http://cdn.dota2.com/apps/dota2/images/tooltips/cooldown.png"]];
        [self.view addSubview:cdImage];
        
        UILabel *cdLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+cdImage.frame.size.width+10, _topHeight+20, 50, cdImage.frame.size.height)];
        cdLabel.text = [NSString stringWithFormat:@"%@", cd];
        cdLabel.textColor = [UIColor orangeColor];
        cdLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [self.view addSubview:cdLabel];
    }

    if (![mc isEqualToNumber:@0]) { // 0 = FALSE = NO
        UIImageView *mcImage = [[UIImageView alloc] initWithFrame:CGRectMake([cd isEqualToNumber:@0] ? 8:mainWidth/2, _topHeight+20, 22, 22)]; //x起点位置要判断前面一个元素是否为空，如国为空，就放到前面，否则就放到屏幕中间
        [mcImage sd_setImageWithURL:[NSURL URLWithString:@"http://cdn.dota2.com/apps/dota2/images/tooltips/mana.png"]];
        [self.view addSubview:mcImage];
        
        UILabel *mcLabel = [[UILabel alloc] initWithFrame:CGRectMake(([cd isEqualToNumber:@0] ? 8:mainWidth/2)+mcImage.frame.size.width+10, _topHeight+20, 50, mcImage.frame.size.height)];
        mcLabel.text = [NSString stringWithFormat:@"%@", mc];
        mcLabel.textColor = [UIColor orangeColor];
        mcLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
        [self.view addSubview:mcLabel];
    }
    
    if (![cd isEqualToNumber:@0] || ![mc isEqualToNumber:@0]) {
        _topHeight += 20+22; //距离上一个元素20,图片高22
    }
    
    NSString *loreStr = [self.itemDetail objectForKey:@"lore"];
    if (![loreStr isEqualToString:@""]) {
        UILabel *loreLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, _topHeight+20, mainWidth-16, 100)];
        loreLabel.text = loreStr;
        loreLabel.textColor = [UIColor grayColor];
        loreLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
        loreLabel.numberOfLines = 0;
        [loreLabel sizeToFit];
        [self.view addSubview:loreLabel];
        _topHeight += 20+loreLabel.frame.size.height;
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


//过滤一些html标签
- (NSString *)filterHtml:(NSArray *)srcArr {
    //NSLog(@"%lu", (unsigned long)[srcArr count]);
    //NSLog(@"%@", srcArr);
    //匹配字符串中html标签的正则表达式
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"(<.+?>)|\r|\n"
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil ]; //|\n|\r
    
    NSMutableString *resultByFilter = [[NSMutableString alloc] init];
    for (NSString *str in srcArr) {
        if (!str) {
            continue;
        }
        NSString *strRes = [regex stringByReplacingMatchesInString:str
                                                           options:0
                                                             range:NSMakeRange(0, [str length])
                                                      withTemplate:@""];
        
        [resultByFilter appendString:[NSString stringWithFormat:@"%@\n", strRes] ]; //这一步的重复性不是很大，可以考虑保存到一个数组，最后用数组的[componentsJoinedByString:@"\n"]方法将数组合并成字符串
        
    }
    
    //去掉换行符
    NSString *finalRes = [resultByFilter stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    
    return finalRes;
}

@end
