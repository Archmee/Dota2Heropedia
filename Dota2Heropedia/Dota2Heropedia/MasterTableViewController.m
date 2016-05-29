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

@interface MasterTableViewController ()

@property (nonatomic) NSString *docPath; //程序存放文件的路径

@property (nonatomic) NSArray *heroesNameList;
/* heroesNameList Array 数据结构
 ["axe", "antimage" ....]
 */

@property (nonatomic) NSDictionary *heroesList;
/* heroesList Dictionary的数据结构
 "antimage":{
 "dname":"敌法师",
 "u":"Anti-Mage",
 "pa":"agi",
 "attribs":{
 "str":{
 "b":22,
 "g":"1.20"
 },
 "int":{
 "b":15,
 "g":"1.80"
 },
 "agi":{
 "b":22,
 "g":"2.80"
 },
 "ms":315,
 "dmg":{
 "min":27,
 "max":31
 },
 "armor":2.08
 },
 "dac":"近战",
 "droles":"核心 - 逃生 - 爆发"
 },
 */
@property (nonatomic) NSDictionary *heroesBio;

 /* heroesBio Dictionay的数据结构
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
 },
*/

@property (nonatomic) NSURLSession *session;

@end

@implementation MasterTableViewController

/*----------NOTE------------
 iOS新规定必须使用https安全连接，但是我们下面有的用了http，而个别使用的https，但是不是每个url都支持了https，所以不支持https的url只能用http，这个时候，我们就要将该域名添加至Info.plist的ATS选项中作为例外情况，QAQ
--------------------------*/

-(void)fetchHeroesListData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropediadata/?feeds=herodata&l=schinese";
    /* l=schinese 是根据在dota2.com官网右上角切换不同语言时获取到的，如果我切换其他语言，相应语言的参数值都可以在url中获取到，我们甚至可以将那个语言列表拿到本地来存储，然后让用户切换不同的语言来做到多语言版本，当然，现在还没尝试，是否可行。
     l=schinese 是 简体中文（simplified chinese）,其他随便什么参数都是返回英文。其实这里很疑惑的就是，在网页端除了制定参数l＝en或l＝english外，
     其他任何参数都返回中文数据，不知是什么原因，但是据我猜想：
        一有可能是服务器代码很混乱，没有严格的文档
        二也有可能这是服务器区分了Web和客户端（iOS活着android），然后故意增加取到数据的难度
        三种可能是通过Web访问api的时候，服务器获取到我的ip是在中国大陆，所以只要在没有明确指定语言的情况下都默认返回中文（也有可能和iOS一样是根据请求体中的内容来返回），而iOS则根据系统时区或系统语言来返回（我的iOS Simulator是英语）
     
     haha, 经过验证，我将模拟器的语言设置为中文后，果然和Web端保持了同步，😄
     而web端，原理类似，浏览器早就获取了你的地区信息，在请求头中可以查看到Accept-Language选项，也是根据系统语言来设置的
     
     结论就是，web和iOS都是类似，如果在参数中指定了官方提供的范围内的语言参数，就返回参数指定的语言，如果没指定或者指定了一些服务器无法区分的参数呢，就根据用户系统语言来返回（通过网络发送的请求体中会提供Accept-Language）
     
     TODO：验证此问题的最好方法就是抓包，看看发送的请求体中的内容
     */
    
    NSURLSessionDataTask *task = [self.session dataTaskWithURL: [NSURL URLWithString: urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSDictionary *jsonSer = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:NSJSONReadingMutableContainers
                                                                                                    error:nil];
                                                 self.heroesList = [jsonSer objectForKey:@"herodata"];
                                                 self.heroesNameList = [self.heroesList allKeys];
                                                 [self.heroesList writeToFile:[self.docPath stringByAppendingPathComponent:@"heroesList.plist"] atomically:YES];
                                                 
                                                 //该函数是为了让这段代码块中的代码在主线程中执行，而不是在背景线程执行
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     [self.tableView reloadData]; //当数据从网络请求成功后，要刷新表
                                                 });
                                             }];
    
    [task resume];
}

- (void)fetchHeroesBioData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropickerdata?v=zh"; //没有v参数是英文，v＝zh, 此处使用http连接
    
    //create session data task
    NSURLSessionDataTask *task = [self.session dataTaskWithURL: [NSURL URLWithString: urlString]
                                              completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            self.heroesBio = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:kNilOptions
                                                                                                      error:nil];
                                            [self.heroesBio writeToFile:[self.docPath stringByAppendingPathComponent:@"heroesBio.plist"] atomically:YES];
                                        }];
    //start task
    [task resume];
}

- (void)setupDataSource {
    //get heroes list
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.docPath stringByAppendingPathComponent:@"heroesList.plist"]]) {
        self.heroesList = [NSDictionary dictionaryWithContentsOfFile:[self.docPath stringByAppendingPathComponent:@"heroesList.plist"]];
        self.heroesNameList = [self.heroesList allKeys];
    } else {
        [self fetchHeroesListData];
    }
    
    //get bio data
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self.docPath stringByAppendingPathComponent:@"heroesBio.plist"]]) {
        self.heroesBio = [NSDictionary dictionaryWithContentsOfFile:[self.docPath stringByAppendingPathComponent:@"heroesBio.plist"]];
    } else {
        [self fetchHeroesBioData];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    //获取保存文件路径
    self.docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];;
    //配置和创建可重用的session
    self.session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] ];
    //获取数据源
    [self setupDataSource];

    self.title = @"Dota2 英雄百科";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleDone target:nil action:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailViewController *DetailVC = [segue destinationViewController];
        
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        
        NSString *name = self.heroesNameList[index.row];
        NSMutableDictionary *selectedHero = [self.heroesList objectForKey: name];
        
        [selectedHero setObject: name forKey:@"ename"];
        [selectedHero setObject: [[self.heroesBio objectForKey:name] objectForKey:@"bio"] forKey:@"bio"];
        
        
        DetailVC.heroIntro = selectedHero;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
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
    
    cell.nameLabel.text = [[self.heroesList objectForKey:realName] objectForKey:@"dname"];
    cell.typeLabel.text = [[self.heroesList objectForKey:realName] objectForKey:@"dac"];

    return cell;
}

@end
