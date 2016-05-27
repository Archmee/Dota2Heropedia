//
//  MasterTableViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/5/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "MasterTableViewController.h"
#import "DetailViewController.h"
#import "HeroItemTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h> //导入第三方库

#define API_KEY @"87294A1C296C1FB71635BC8CA95F2028"

@interface MasterTableViewController ()

@property (nonatomic) NSMutableArray *heroes;
@property (nonatomic) NSDictionary *heroesDetail;

@property (nonatomic) NSURLSession *session;

@end

@implementation MasterTableViewController

/*----------NOTE------------
 iOS新规定必须使用https安全连接，但是我们下面有的用了http，而个别使用的https，但是不是每个url都支持了https，所以不支持https的url只能用http，这个时候，我们就要将该域名添加至Info.plist的ATS选项中作为例外情况，QAQ
--------------------------*/

- (void)fetchHeroesList {
    NSString *urlString = [NSString stringWithFormat:@"https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=%@&language=zh_cn", API_KEY]; //最后的language参数有zh_cn和en可选，此处用的https
    
    //create configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    //create session for reuse
    self.session = [NSURLSession sessionWithConfiguration: defaultConfigObject ]; //如果用同名但是带delegate参数的方法就可以在下面block代码块中省去dispatch_async()的调用，原因未知，带参数代码为： delegate: nil delegateQueue: [NSOperationQueue mainQueue]
    //create session data task
    NSURLSessionDataTask *task = [self.session dataTaskWithURL: [NSURL URLWithString: urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSDictionary *serJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:nil];//options:NSJSONReadingMutableContainers 这个参数决定了返回的数据是否可以修改
                                                 self.heroes = [[serJSON objectForKey:@"result"] objectForKey:@"heroes"];
                                                 /* heroes数组中每个元素的结构
                                                  {
                                                  "name": "npc_dota_hero_luna",
                                                  "id": 48,
                                                  "localized_name": "露娜"
                                                  }*/
                                                 
                                                 //该函数是为了让这段代码块中的代码在主线程中执行，而不是在背景线程执行
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self.tableView reloadData]; //当数据从网络请求成功后，要刷新表
                                                 });
                                             }];
    //start task
    [task resume];
}

- (void)fetchHeroesDetail {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropickerdata?v=zh"; //没有v参数是英文，v＝zh, 此处使用http连接
    
    //create session data task
    NSURLSessionDataTask *task = [self.session dataTaskWithURL: [NSURL URLWithString: urlString]
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            self.heroesDetail = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:NSJSONReadingMutableContainers
                                                                                                      error:nil];
                                            /* JSON数据中每个元素的结构
                                             "antimage":{
                                                "name":"Anti-Mage",
                                                "bio":"The monks of ... ",
                                                "atk":"melee",
                                                "atk_l":"Melee",
                                                "roles":[
                                                         "Carry",
                                                         "Escape",
                                                         "Nuker"
                                                         ],
                                                "roles_l":[
                                                           "Carry",
                                                           "Escape",
                                                           "Nuker"
                                                           ]
                                            },*/
                                        }];
    //start task
    [task resume];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Dota2 英雄百科";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
    
    
    [self fetchHeroesList];
    [self fetchHeroesDetail];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailViewController *DetailVC = [segue destinationViewController];
        
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        NSMutableDictionary *selectedHero = self.heroes[index.row]; //仅仅是指向同一个地址而已
        NSDictionary *heroItem = [self.heroesDetail objectForKey: [selectedHero objectForKey:@"name"] ];
    
        [selectedHero setObject:[heroItem objectForKey:@"atk_l"] forKey:@"atk_l" ];
        [selectedHero setObject:[heroItem objectForKey:@"roles_l"] forKey:@"roles_l" ];
        [selectedHero setObject:[heroItem objectForKey:@"bio"] forKey:@"bio" ];
        
        DetailVC.heroIntro = selectedHero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.heroes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HeroItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeroItemCell" forIndexPath:indexPath];
    
    // Configure the cell...
    
    NSString *name = [self.heroes[indexPath.row] objectForKey:@"name"];
    NSString *realName = [name stringByReplacingOccurrencesOfString:@"npc_dota_hero_" withString: @""]; //将字符串中指定字符串替换为空
    [self.heroes[indexPath.row] setObject:realName forKey:@"name" ]; //将已经处理好的真实名字替代原值，便于后续使用
    
    NSString *urlStr = [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/heroes/%@_hphover.png", realName];
    [cell.iconImage sd_setImageWithURL: [NSURL URLWithString: urlStr]];
    
    cell.nameLabel.text = [self.heroes[indexPath.row] objectForKey:@"localized_name"];
    cell.typeLabel.text = [[self.heroesDetail objectForKey:realName] objectForKey:@"atk_l"];

    return cell;
}

@end
