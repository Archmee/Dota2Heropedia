//
//  DataMode.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "DataMode.h"
@interface DataMode()
{
    NSURLSession *_session;
    NSString *_docPath; //程序存放文件的路径

}
@end

@implementation DataMode

- (instancetype)init {
    self = [super init];
    if (self) {
        //获取保存文件路径
        _docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        //配置和创建可重用的session
        _session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] ];
        
        //download heroes list
        if (![self isFileExistsAtPath:HeroesListFile]) {
            [self fetchHeroesListData];
        }
        
        //download bio data
        if (![self isFileExistsAtPath:HeroesBioFile]) {
            [self fetchHeroesBioData];
        }
        
        //download ability data
        if (![self isFileExistsAtPath:HeroesAbilityFile]) {
            [self fetchHeroesAbilityData];
        }
        
        //download items data
        if (![self isFileExistsAtPath:HeroesItemsFile]) {
            [self fetchHeroesItemsData];
        }
        
        self.itemQual = @{@"consumable": @"消耗品",
                          @"component": @"属性",
                          @"common": @"普通",
                          @"rare": @"辅助",
                          @"epic": @"武器",
                          @"artifact": @"圣物",
                          @"secret_shop": @"神秘商店",
                          };
        
        //NSLog(@"%@", _docPath);
    }
    return self;
}

+ (instancetype)shareModel { //单例
    // 1 声明一个静态变量
    static DataMode *_shareModel = nil;
    
    // 2 声明一个静态这是 dispatch_one_t，确保这些初始化代码只能被执行一次
    static dispatch_once_t oncePredicate;
    
    // 3 使用 GCD 执行一个 block 来初始化
    dispatch_once(&oncePredicate, ^{
        _shareModel = [[self alloc] init];
    });
    
    return _shareModel;
}


- (BOOL)isFileExistsAtPath:(NSString *)fileName {
    return [[NSFileManager defaultManager] fileExistsAtPath:[_docPath stringByAppendingPathComponent:fileName] ];
}

-(NSDictionary *)getFileData:(NSString *)fileName {
    return [NSDictionary dictionaryWithContentsOfFile:[_docPath stringByAppendingPathComponent:fileName]];
}


/*----------NOTE------------
 iOS新规定必须使用https安全连接，但是我们下面有的用了http，而个别使用的https，但是不是每个url都支持了https，所以不支持https的url只能用http，这个时候，我们就要将该域名添加至Info.plist的ATS选项中作为例外情况，QAQ
 --------------------------*/

-(void)fetchHeroesListData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropediadata/?feeds=herodata&l=schinese";
    /* l=schinese 是根据在dota2.com官网右上角切换不同语言时获取到的，如果我切换其他语言，相应语言的参数值都可以在url中获取到，我们甚至可以将那个语言列表拿到本地来存储，然后让用户切换不同的语言来做到多语言版本，当然，现在还没尝试，是否可行。
     l=schinese 是 简体中文（simplified chinese）,其他随便什么参数都是返回英文。其实这里很疑惑的就是，在网页端除了制定参数l＝en或l＝english外，
     其他任何参数都返回中文数据，不知是什么原因，但是据我猜想：
     一 有可能是服务器代码很混乱，没有严格的文档
     二 也有可能这是服务器区分了Web和客户端（iOS活着android），然后故意增加取到数据的难度
     三 可能是通过Web访问api的时候，服务器获取到我的ip是在中国大陆，所以只要在没有明确指定语言的情况下都默认返回中文（也有可能和iOS一样是根据请求体中的内容来返回），而iOS则根据系统时区或系统语言来返回（我的iOS Simulator是英语）
     
     haha, 经过验证，我将模拟器的语言设置为中文后，果然和Web端保持了同步，😄
     而web端，原理类似，浏览器早就获取了你的地区信息，在请求头中可以查看到Accept-Language选项，也是根据系统语言来设置的
     
     结论就是，web和iOS都是类似，如果在参数中指定了官方提供的范围内的语言参数，就返回参数指定的语言，如果没指定或者指定了一些服务器无法区分的参数呢，就根据用户系统语言来返回（通过网络发送的请求体中会提供Accept-Language）
     
     TODO：验证此问题的最好方法就是抓包，看看发送的请求体中的内容
     但是现在看来没必要了。。。
     */
    
    NSURLSessionDataTask *task = [_session dataTaskWithURL: [NSURL URLWithString: urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSDictionary *jsonSer = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:NSJSONReadingMutableContainers
                                                                                                           error:nil];
                                                 NSDictionary *heroesList = [jsonSer objectForKey:@"herodata"];
                                                 jsonSer = nil;
                                                 
                                                 [heroesList writeToFile:[_docPath stringByAppendingPathComponent:HeroesListFile] atomically:YES];
                                                 
                                                 //该函数是为了让这段代码块中的代码在主线程中执行，而不是在背景线程执行
                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                     //发出通知，已经获取到数据
                                                     [[NSNotificationCenter defaultCenter] postNotificationName:@"reloadTable" object:nil];
                                                 });
                                                 
                                                 
                                             }];
    
    [task resume];
}

- (void)fetchHeroesBioData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropickerdata?l=schinese"; //此处使用http连接
    
    //create session data task
    NSURLSessionDataTask *task = [_session dataTaskWithURL: [NSURL URLWithString: urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSDictionary *bio = [NSJSONSerialization JSONObjectWithData:data
                                                                                                     options:kNilOptions
                                                                                                       error:nil];
                                                 [bio writeToFile:[_docPath stringByAppendingPathComponent:HeroesBioFile] atomically:YES];
                                             }];
    //start task
    [task resume];
}

- (void)fetchHeroesAbilityData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropediadata/?feeds=abilitydata&l=schinese";
    
    NSURLSessionDataTask *task = [_session dataTaskWithURL:[NSURL URLWithString:urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSDictionary *ability = [NSJSONSerialization JSONObjectWithData:data
                                                                                                         options:kNilOptions
                                                                                                           error:nil];
                                                 [[ability objectForKey:@"abilitydata"] writeToFile: [_docPath stringByAppendingPathComponent:HeroesAbilityFile] atomically:YES];
                                             }];
    [task resume];
}

- (void)fetchHeroesItemsData {
    NSString *urlString = @"http://www.dota2.com/jsfeed/heropediadata/?feeds=itemdata&l=schinese";
    
    NSURLSessionDataTask *task = [_session dataTaskWithURL:[NSURL URLWithString:urlString]
                                             completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                 NSMutableDictionary *items = [NSJSONSerialization JSONObjectWithData:data
                                                                                                              options:NSJSONReadingMutableContainers
                                                                                                                error:nil];
                                                 items = [items objectForKey:@"itemdata"];//取出需要的列表覆盖原数据
                                                 NSArray *itemsList = [items allKeys];//为了遍历
                                                 //过滤空空对象值 null
                                                 for (NSString *itemName in itemsList) {
                                                     
                                                     id component = [[items objectForKey:itemName] objectForKey:@"components"];
                                                     if ([component isEqual:[NSNull null]]) { //isKindOfClass:[NSNull class]
                                                         [[items objectForKey:itemName] setObject:@"" forKey:@"components"]; //其实这个值对我们没多大用处，不用判断，直接remove掉也可以
                                                     }
                                                     if (![[items objectForKey:itemName] objectForKey:@"created"]) { //不起作用
                                                         //NSLog(@"%@", [[items objectForKey:itemName] objectForKey:@"created"]);
                                                         [items removeObjectForKey:itemName];
                                                     }
                                                 }
                                                 
                                                 [items writeToFile: [_docPath stringByAppendingPathComponent:HeroesItemsFile] atomically:YES];
                                             }];
    [task resume];
}
@end
