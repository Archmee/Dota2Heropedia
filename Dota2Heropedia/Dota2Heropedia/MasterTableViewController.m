//
//  MasterTableViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/5/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "MasterTableViewController.h"
#import "HeroItemTableViewCell.h"
#import "DetailTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h> //导入第三方库

#import "DataMode.h"

@interface MasterTableViewController ()

@property (nonatomic) NSArray *heroesNameList;
@property (nonatomic) NSDictionary *heroesList;

@end

@implementation MasterTableViewController

- (void)setupDataSource {
    self.heroesList = [[DataMode shareModel] getFileData:HeroesListFile];
    self.heroesNameList = [self.heroesList allKeys];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取数据源，其实第一次启动app时，这个setupDataSource初始化的数据为空，等到接收到通知后再次初始化数据才有用，但是第二次启动app就依靠这个调用了，直接从文件读取
    [self setupDataSource];
    
    self.title = @"Dota2 英雄百科";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    //给通知中心添加观察者，得到通知后便执行指定的函数。
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiReloadData) name:@"reloadTable" object: nil];
}

//接到通知中心发出的通知，执行该函数
-(void)notiReloadData {
    [self setupDataSource]; //数据下载完成后就要初始化组装数据
    
    [self.tableView reloadData]; //刷新表格
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"reloadTable" object:nil]; //相应工作完成后，要移除 observer
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailTableViewController *DetailVC = [segue destinationViewController];
        
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        NSString *realName = self.heroesNameList[index.row];
        NSMutableDictionary *selectedHero = [self.heroesList objectForKey: realName];
        [selectedHero setObject:realName forKey:@"ename"];
        
        DetailVC.heroIntro = selectedHero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [[SDWebImageManager sharedManager] cancelAll];// 1.停止所有的子线程下载
    [[[SDWebImageManager sharedManager] imageCache] clearMemory];// 2.清空SDWebImage保存的所有内存缓存
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.heroesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeroItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeroItemCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSString *realName = self.heroesNameList[indexPath.row];
    NSString *urlStr = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_hphover.png", realName];
    [cell.iconImage sd_setImageWithURL: [NSURL URLWithString: urlStr]];
    
    NSString *dac = [NSString stringWithFormat:@"(%@)", [[self.heroesList objectForKey:realName] objectForKey:@"dac"]];
    cell.nameLabel.text = [[self.heroesList objectForKey:realName] objectForKey:@"dname"];
    cell.typeLabel.text = dac;
 //   [cell.nameLabel sizeToFit];
//    [cell.typeLabel sizeToFit];
    cell.rolesLabel.text = [[self.heroesList objectForKey:realName] objectForKey:@"droles"];

    return cell;
}

@end
