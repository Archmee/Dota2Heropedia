//
//  ItemsTableViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/24.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "ItemsTableViewController.h"
#import "ItemTableViewCell.h"
#import "DataMode.h"
#import "ItemsDetailViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

@interface ItemsTableViewController ()

@property (nonatomic) NSDictionary *itemsList;
@property (nonatomic) NSArray *itemsNameList;

@end

@implementation ItemsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupDataSource];
    
    self.title = @"物品浏览";
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:nil];

}

-(void)setupDataSource {
    self.itemsList = [[DataMode shareModel] getFileData:HeroesItemsFile];
    self.itemsNameList = [[self.itemsList allKeys] sortedArrayUsingSelector:@selector(compare:)]; //sortedArrayUsingSelector:@selector(compare:)
    
    //NSLog(@"%@", self.itemsList);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.itemsNameList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ItemTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ItemCell" forIndexPath:indexPath];
    
    NSString *itemName = [NSString stringWithFormat:@"%@", self.itemsNameList[indexPath.row]];
    NSDictionary *curItem = [self.itemsList objectForKey: itemName ];
    
//    NSLog(@"%@",[[curItem objectForKey:@"cost"] class]);
//    if ([[curItem objectForKey:@"cost"] isEqualToNumber:@0]) {
//        NSLog(@"null cost");
//
//        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
//    }
    
    [cell.ItemImage sd_setImageWithURL: [NSURL URLWithString:[NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/items/%@_lg.png", itemName]] ];
    cell.itemName.text = [curItem objectForKey:@"dname"];
    [cell.costImage sd_setImageWithURL:[NSURL URLWithString:@"http://cdn.dota2.com/apps/dota2/images/tooltips/gold.png"] ];
    cell.costLabel.text = [NSString stringWithFormat:@"%@", [curItem objectForKey:@"cost"] ];
    cell.qualLable.text = [[[DataMode shareModel] itemQual] objectForKey: [curItem objectForKey:@"qual"] ];
    
    
    return cell;
}

//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showItem"]) {
        ItemsDetailViewController *idVC = segue.destinationViewController;
        NSIndexPath *index = [self.tableView indexPathForSelectedRow];
        NSString *realName = self.itemsNameList[index.row];
        idVC.itemName = realName;
        idVC.itemDetail = [self.itemsList objectForKey:realName];
    }
}



@end
