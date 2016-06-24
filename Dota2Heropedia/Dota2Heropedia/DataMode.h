//
//  DataMode.h
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/23.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import <Foundation/Foundation.h>


#define HeroesListFile      @"heroesList.plist"
#define HeroesBioFile       @"heroesBio.plist"
#define HeroesAbilityFile   @"heroesAbility.plist"
#define HeroesItemsFile     @"heroesItems.plist"


@interface DataMode : NSObject

+ (instancetype)shareModel; //单例
-(NSDictionary *)getFileData:(NSString *)fileName;

@property (nonatomic) NSDictionary *itemQual;

@end
