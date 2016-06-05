//
//  DetailTableViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/5/29.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "DetailTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>

#import "StatusTableViewCell.h"
#import "AbilityTableViewCell.h"
#import "BioTableViewCell.h"

@interface DetailTableViewController ()

@property (nonatomic) NSString *heroName;

@property (nonatomic) NSDictionary *heroesBio;
@property (nonatomic) NSDictionary *heroesAbility;
@property (nonatomic) NSArray *heroesAbilityList;

//view element
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *dacLabel;
@property (weak, nonatomic) IBOutlet UILabel *drolesLabel;

@end

@implementation DetailTableViewController

- (void)setupDataSource {
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];

    self.heroesBio = [[NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"heroesBio.plist"]] objectForKey:self.heroName];
    
    self.heroesAbility = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"heroesAbility.plist"]] ;
    NSArray *ablist = [self.heroesAbility allKeys];
    NSMutableDictionary *tmp = [[NSMutableDictionary alloc] init];
    for (NSString *abName in ablist) {
        if ([abName hasPrefix:[NSString stringWithFormat:@"%@_", self.heroName]]) {
            [tmp setObject:[self.heroesAbility objectForKey:abName] forKey:abName];
        }
    }
    self.heroesAbility = nil;// does it work
    self.heroesAbility = tmp;
    self.heroesAbilityList = [tmp allKeys]; //取得键值数组
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = [self.heroIntro objectForKey:@"dname"];
    self.heroName = [self.heroIntro objectForKey:@"ename"];
    
    NSString *urlStr = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_vert.jpg", self.heroName];
    [self.imageView sd_setImageWithURL:[NSURL URLWithString:urlStr]];
    
    self.dacLabel.text = [self.heroIntro objectForKey:@"dac"];
    self.drolesLabel.text = [self.heroIntro objectForKey:@"droles"];
    
    [self setupDataSource];
    
    //设置一个默认高度，并可自动扩展行高
    self.tableView.estimatedRowHeight = 100;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

//为每个section设置标题，并且显示在section顶部
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = nil;
    if (section == 0) {
        title = @"状态";
    } else if (section == 1) {
        title = @"技能";
    } else if (section == 2) {
        title = @"背景";
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 1) { //只有第1个section才需要多行，第0和2都不需要
        return [self.heroesAbilityList count];
    } else {
        return 1;
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        StatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"StatusCell" forIndexPath:indexPath];
        cell.icon1.image = [UIImage imageNamed:@"int.png"];
        cell.label1.text = [NSString stringWithFormat:@"%@ + %@", self.heroIntro[@"attribs"][@"int"][@"b"], self.heroIntro[@"attribs"][@"int"][@"g"]];

        cell.icon2.image = [UIImage imageNamed:@"attack.png"];
        cell.label2.text = [NSString stringWithFormat:@"%@ - %@", self.heroIntro[@"attribs"][@"dmg"][@"min"], self.heroIntro[@"attribs"][@"dmg"][@"max"]];
        
        cell.icon3.image = [UIImage imageNamed:@"agi.png"];
        cell.label3.text = [NSString stringWithFormat:@"%@ + %@", self.heroIntro[@"attribs"][@"agi"][@"b"], self.heroIntro[@"attribs"][@"agi"][@"g"]];
        
        cell.icon4.image = [UIImage imageNamed:@"speed.png"];
        cell.label4.text = [NSString stringWithFormat:@"%@", self.heroIntro[@"attribs"][@"ms"]];
        
        cell.icon5.image = [UIImage imageNamed:@"str.png"];
        cell.label5.text = [NSString stringWithFormat:@"%@ + %@", self.heroIntro[@"attribs"][@"str"][@"b"], self.heroIntro[@"attribs"][@"str"][@"g"]];
        
        cell.icon6.image = [UIImage imageNamed:@"defense.png"];
        cell.label6.text = [NSString stringWithFormat:@"%@", self.heroIntro[@"attribs"][@"armor"]];

        
        
        return cell;
        
    } else if (indexPath.section == 1) {
        AbilityTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AbilityCell" forIndexPath:indexPath];
        NSDictionary *currentAbility = [self.heroesAbility objectForKey: self.heroesAbilityList[indexPath.row]];
        NSString *urlStr = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/abilities/%@_hp1.png", self.heroesAbilityList[indexPath.row]];
        [cell.imageLabel sd_setImageWithURL: [NSURL URLWithString: urlStr]];

        cell.nameLabel.text = [currentAbility objectForKey:@"dname"];
        cell.introLabel.text = [currentAbility objectForKey:@"desc"];
        cell.introLabel.numberOfLines = 0;

        return cell;
    } else if (indexPath.section == 2) {
        BioTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BioCell" forIndexPath:indexPath];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];//[UIFont systemFontOfSize:17.0 weight:UIFontWeightLight];
        cell.textLabel.text = [self.heroesBio objectForKey:@"bio"];
        
        return cell;
    }
    return nil;
}

@end
