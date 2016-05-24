//
//  MasterTableViewController.m
//  Dota2HeroIntro
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

@property (nonatomic) NSArray *heroes;

@end

@implementation MasterTableViewController

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    NSString *urlString = [NSString stringWithFormat:@"https://api.steampowered.com/IEconDOTA2_570/GetHeroes/v0001/?key=%@&language=zh_cn", API_KEY];
    
    //create configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    //create session
    NSURLSession *session = [NSURLSession sessionWithConfiguration: defaultConfigObject ]; //如果用同名但是带delegate参数的方法就可以在下面block代码块中省去dispatch_async()的调用，原因未知，带参数代码为： delegate: nil delegateQueue: [NSOperationQueue mainQueue]
    //create session data task
    NSURLSessionDataTask *task = [session dataTaskWithURL: [NSURL URLWithString: urlString]
                                        completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                            NSDictionary *serJSON = [NSJSONSerialization JSONObjectWithData:data
                                                                                                    options:kNilOptions
                                                                                                      error:nil];//options:NSJSONReadingMutableContainers
                                            self.heroes = [[serJSON objectForKey:@"result"] objectForKey:@"heroes"];
                                            
                                            //该函数是为了让这段代码块中的代码在主线程中执行，而不是在背景线程执行
                                            dispatch_async(dispatch_get_main_queue(), ^{
                                                [self.tableView reloadData]; //当数据从网络请求成功后，要刷新表
                                            });
                                        }];
    //start task
    [task resume];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Dota2 Heroespedia";
    
    //这是我们读取本地文件的结果，接下来我们在视图将要加载的过程中网络请求来代替
    //NSString *fullFilePath = [[NSBundle mainBundle] pathForResource:@"herolist" ofType:@"plist"];
    //self.heroes = [NSArray arrayWithContentsOfFile: fullFilePath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"ToDetail"]) {
        DetailViewController *DetailVC = [segue destinationViewController];
        NSInteger selectedRow = [[self.tableView indexPathForSelectedRow] row];
        DetailVC.heroIntro = self.heroes[selectedRow]; //其实这里可以利用sender，但是How ？
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
    HeroItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeroItem" forIndexPath:indexPath];
    
    // Configure the cell...
//    NSString *iconImageName = [[[self.heroes[indexPath.row] objectForKey:@"ename"] lowercaseString] stringByAppendingString:@"_hphover.png"];
//    cell.iconImage.image = [UIImage imageNamed: iconImageName];
//    cell.nameLabel.text = [self.heroes[indexPath.row] objectForKey:@"localized_name"];
//    cell.typeLabel.text = [self.heroes[indexPath.row] objectForKey:@"type"];
    
    NSString *urlStr = @"http://cdn.dota2.com/apps/dota2/images/heroes/drow_ranger_hphover.png";
    [cell.iconImage sd_setImageWithURL: [NSURL URLWithString: urlStr]];
    
    cell.nameLabel.text = [self.heroes[indexPath.row] objectForKey:@"localized_name"];

    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
