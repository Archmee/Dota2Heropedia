//
//  AbilityViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/19.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "AbilityViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
#import "AbilityViewController.h"

#define mainWidth self.view.frame.size.width
#define mainHeight self.view.frame.size.height
//navTop是导航栏的高度＋状态栏高度得到的 self.navigationController.navigationBar.frame.size.height+[UIApplication sharedApplication].statusBarFrame.size.height
//注意：因为将storyboard中的从UIView改为了UIScrollView的关系，现在不需要navTop的高度了，所以暂时将其改为0，如果纯代码添加scrollView的话就要用到
#define navTop 0

@interface AbilityViewController ()

//顶部
@property (nonatomic) UIImageView *headImage;
@property (nonatomic) UILabel *descLabel;
//中间
@property (nonatomic) UILabel *noteLabel;
@property (nonatomic) UILabel *affectsLabel;
@property (nonatomic) UILabel *attribLable;
//底部
@property (nonatomic) UIView *videoView;

@property (nonatomic) UIButton *playButton;
@property (nonatomic) UILabel *timeLable;


@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;

@property (nonatomic) BOOL isPlaying; //是否正在播放
@property (nonatomic) BOOL canPlay; //能否播放，只要视频正在加载以及加载失败触摸播放按钮都不会做出反应

@property (nonatomic) NSInteger totalTime;
@property (nonatomic) NSInteger currentTime;

@end

@implementation AbilityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 这里保留的代码是为了单独调试改界面时用的
    /*self.abilityName = @"antimage_mana_break";
    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSDictionary *heroesAbility = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"heroesAbility.plist"]];
    self.hero = [heroesAbility objectForKey:self.abilityName];//antimage_mana_break*/
    //NSLog(@"%@", self.hero);
    
    self.title = [self.hero objectForKey:@"dname"];
    
    [self setHeadInfo];
    [self setIntroInfo];
    [self setVideoInfo];
    
    
    //解决scrollView其实有两种方案，一种是在storyboard中选中该视图的view设置Class为UISCrollView，然后在下面设置ScrollView内容的宽高
    //放在末尾是为了让前面的元素大小都初始化完成后再执行
    [(UIScrollView *)self.view setContentSize:CGSizeMake(mainWidth, navTop+self.headImage.frame.size.height+8+10+self.noteLabel.frame.size.height+10+(self.affectsLabel.frame.size.height >= self.attribLable.frame.size.height ? self.affectsLabel.frame.size.height : self.attribLable.frame.size.height)+10+300+8)];//这个高度是上面所有元素Y轴的位置相加直到播放视频位置，最后加上视频的高度300，再加8是为了让视频下面留一点白边，而不让视频紧贴着下边缘
    
    //第二种就是 完全代码创建一个 UIScrollView 然后添加到self.view，然后后面所有针对self.view添加的元素操作都要放在UIScrollView上了
    /*UIScrollView *scroll =  [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, mainWidth, mainHeight)];
    scroll.contentSize = CGSizeMake(mainWidth, navTop+self.headImage.frame.size.height+8+10+self.noteLabel.frame.size.height+10+(self.affectsLabel.frame.size.height >= self.attribLable.frame.size.height ? self.affectsLabel.frame.size.height : self.attribLable.frame.size.height)+10+300+8);
    scroll.showsVerticalScrollIndicator = YES;
    
    [self.view addSubview:scroll];
    [self.view sendSubviewToBack:scroll]; //sendSubviewToBack是把一个视图放到一个视图的后面，bringSubviewToFront 是把一个视图放到一个视图的前面
    */
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setHeadInfo {
    //定义ability展示图
    self.headImage = [[UIImageView alloc] initWithFrame:CGRectMake(8, navTop+8, 105, 105)];
    [self.headImage sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://cdn.dota2.com/apps/dota2/images/abilities/%@_hp2.png", self.abilityName ]]];
    
    //定义展示图右边的说明文字
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectMake(8+self.headImage.frame.size.width+8, navTop+8, mainWidth-16-self.headImage.frame.size.width-8, self.headImage.frame.size.height)];
    NSString *descText = [[self.hero objectForKey:@"desc"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    self.descLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14];
    self.descLabel.attributedText = [self setAttributedString:descText fotHeight:2];
    self.descLabel.numberOfLines = 0;
    //[self.descLabel sizeToFit];//如果设置了下面的，就不用设置这个了，这个是让label自动缩放的
    [self.descLabel adjustsFontSizeToFitWidth]; //让字体自动变小一点，但是后面发觉还是没能全部解决问题，部分超出字体被截掉
    
    [self.view addSubview:self.headImage];
    [self.view addSubview:self.descLabel];
}

-(void)setIntroInfo {
    //定义技能注意文字
    NSString *noteString = [[self.hero objectForKey:@"notes"] stringByReplacingOccurrencesOfString:@"<br />" withString:@" "];
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, navTop+self.headImage.frame.size.height+8+10, mainWidth-16, 40)];
    noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    noteLabel.textColor = [UIColor blueColor];
    noteLabel.attributedText = [self setAttributedString:noteString fotHeight:4];
    noteLabel.numberOfLines = 0;
    [noteLabel sizeToFit];
    
    self.noteLabel = noteLabel;
    [self.view addSubview:noteLabel];
    noteLabel = nil;
    
    ////处理左半边的affects
    //将字符串按照html标签<br/>来分割
    NSArray *affectsList = [[self.hero objectForKey:@"affects"] componentsSeparatedByString:@"<br />"];
    NSString *resultByFilter = [self filterHtml:affectsList];
    affectsList = nil;
    
    UILabel *affectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, navTop+self.headImage.frame.size.height+8+10+self.noteLabel.frame.size.height+10, mainWidth/2-8, 100)];
    affectsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    //label.text = resultByFilter;
    affectsLabel.attributedText = [self setAttributedString:resultByFilter fotHeight:4];
    affectsLabel.numberOfLines = 0;
    [affectsLabel sizeToFit];
    
    self.affectsLabel = affectsLabel;
    [self.view addSubview:affectsLabel];
    affectsLabel = nil;
    
    ////处理右半边的attib,和上面步骤一样
    NSArray *attribList = [[self.hero objectForKey:@"attrib"] componentsSeparatedByString:@"<br />"];
    resultByFilter = [self filterHtml:attribList]; //reuse
    attribList = nil;
    //NSLog(@"%@", resultByFilter);
    
    UILabel *attribLable = [[UILabel alloc] initWithFrame:CGRectMake(mainWidth/2+8, navTop+self.headImage.frame.size.height+8+10+self.noteLabel.frame.size.height+10, mainWidth/2-8-8, 100)];
    attribLable.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    attribLable.attributedText = [self setAttributedString:resultByFilter fotHeight:5];
    attribLable.numberOfLines = 0;
    [attribLable sizeToFit];
    
    self.attribLable = attribLable;
    [self.view addSubview: attribLable];
    attribLable = nil;
}

-(void)setVideoInfo {
    //取有效视频链接
    NSString *aVideoURLName = [[self.hero objectForKey:@"hurl"] lowercaseString];
    if ([aVideoURLName containsString:@"-"]) {
        aVideoURLName = [self.abilityName stringByReplacingOccurrencesOfString:[aVideoURLName stringByReplacingOccurrencesOfString:@"-" withString:@""] withString:aVideoURLName];
        
    } else {
        aVideoURLName = self.abilityName;
    }
    
    //该视频url对大多数技能有效，但是部分链接不规则，所以会加载失败
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://dota2.dl.wanmei.com/dota2/video/abilities/%@.mp4", aVideoURLName]];
    //NSLog(@"%@", url);
    
    //设置播放器界面
    self.videoView = [[UIView alloc] initWithFrame: CGRectMake(8, navTop+self.headImage.frame.size.height+8+10+self.noteLabel.frame.size.height+10+(self.affectsLabel.frame.size.height >= self.attribLable.frame.size.height ? self.affectsLabel.frame.size.height : self.attribLable.frame.size.height)+10, mainWidth-16, 300)]; //Y的坐标位置取紧挨着上面的lable的最高的高度，这样不会遮挡上面的内容
    [self.view addSubview:self.videoView];
    
    //设置播放器
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer: self.player];
    layer.frame = self.videoView.bounds;
    layer.backgroundColor = [[UIColor blackColor] CGColor];
    [self.videoView.layer addSublayer:layer];
    
    /*UIImageView *videoPoster = [[UIImageView alloc] initWithImage:[self getImage:url] ];
    [self.videoView addSubview:videoPoster];*/
    
    //展示在播放器中的其他元素
    [self showLoreLabel];
    [self showPlayButton];
    [self showTimeLable];
    
    //添加一个观察者观察其播放时间变化状况，当dealloc的时候要移除observer
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSString *new = change[NSKeyValueChangeNewKey];
        if ([new integerValue] == AVPlayerItemStatusReadyToPlay) {//视频准备播放
            self.canPlay = YES; //已经准备好可以播放了

            self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
            self.timeLable.text = [self formmatTimeToString:self.totalTime];
            
            __weak AbilityViewController *weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
                AbilityViewController *innerSelf = weakSelf;
                NSInteger currentTime = CMTimeGetSeconds(weakSelf.playerItem.currentTime);
                NSInteger leftTime = innerSelf.totalTime - currentTime;
                if (leftTime == 0) { //剩余时间为0表示播放结束
                    [innerSelf stopVideo];
                    innerSelf.timeLable.text = [innerSelf formmatTimeToString:innerSelf.totalTime];
                } else { //播放倒计时
                    innerSelf.timeLable.text = [innerSelf formmatTimeToString:leftTime];
                }
                
                
            }];
        } else { //视频加载失败
            self.canPlay = NO;
            self.timeLable.text = @"加载失败";
        }
    }
}


- (void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"]; //如果不移除会报错EXC_BAD_ACCESS
}

-(void)showLoreLabel {
    UILabel *loreLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, mainWidth-16-16, 50)];
    loreLabel.textColor = [UIColor grayColor];
    loreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    loreLabel.textAlignment = NSTextAlignmentCenter; //字体对齐方式
    //loreLabel.text = [NSString stringWithFormat:@" %@ ", [self.hero objectForKey:@"lore"] ];
    loreLabel.attributedText = [self setAttributedString:[self.hero objectForKey:@"lore"] fotHeight:4];
    loreLabel.numberOfLines = 0;
    [loreLabel sizeToFit];
    
    [self.videoView addSubview:loreLabel];
}

- (void)showPlayButton {
    self.isPlaying = NO; //初始化为未播放状态
    self.canPlay = NO; //初始化不能播放状态,等待加载完成再更改
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(mainWidth/2-20, 255, 40, 40)];
    playButton.layer.cornerRadius = playButton.bounds.size.width / 2; //no #import <QuartzCore/QuartzCore.h>
    [playButton setBackgroundColor:[UIColor whiteColor]];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play_128.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(touchEvent) forControlEvents:UIControlEventTouchUpInside]; //触摸按钮就是播放或暂停
    
    [self.videoView addSubview:playButton];
    self.playButton = playButton;
}

- (void)showTimeLable {
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: CGRectMake(mainWidth-8-80, 255, 100, 40)];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    //timeLabel.textAlignment = NSTextAlignmentLeft; //字体对齐方式
    
    timeLabel.text = @"正在加载...";
    
    [self.videoView addSubview:timeLabel];
    self.timeLable = timeLabel;
}

- (void)touchEvent {
    if (!self.canPlay) { //如果不能播放，则不处理点击事件
        return ;
    }
    
    if (self.isPlaying) { //如果正在播放时停止了按钮，则停止
        [self stopVideo];
        
    } else { //正在播放时点击了播放按钮，则开始
        [self playVideo];
    }
}

- (void)playVideo {
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"stop_128.png"] forState:UIControlStateNormal];
    [self.player play];
    self.isPlaying = YES;
}

- (void)stopVideo {
    [self.playButton setBackgroundImage:[UIImage imageNamed:@"play_128.png"] forState:UIControlStateNormal];
    [self.player seekToTime:kCMTimeZero];
    [self.player pause];
    self.isPlaying = NO;
}

#pragma mark - 自定义功能函数
//设置字体段落格式，这里仅仅设置了行高
- (NSMutableAttributedString *)setAttributedString:(NSString *)src fotHeight:(NSInteger)height{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: src];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = height; //行高5px
    [attr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, [src length])];
    
    return attr;
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

    //[resultByFilter deleteCharactersInRange:NSMakeRange([resultByFilter length]-1, 1)]; //最后一个\n字符替换掉，不然整个label会多一个空行
    
//    NSLog(@"%@", finalRes);
//    NSLog(@"%lu", [finalRes length]);
    
    return finalRes;
}

- (NSString *)formmatTimeToString:(NSInteger)seconds {
    int hour, min, sec;
    hour = (int)(seconds / 3600);
    min = (int)((seconds % 3600) / 60);
    sec = (int)(seconds % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
}

//这是获取播放前的一个视频截图，但是无效，所以暂时不用
- (UIImage *)getImage:(NSURL *)videoURL {
    //    NSURL *url = [[NSBundle mainBundle] URLForResource:@"anti-mage_blink" withExtension:@"mp4"];
    
    AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:videoURL options:nil];
    NSParameterAssert(urlAsset);
    //获取视频时长，单位：秒
    //NSLog(@"%llu", urlAsset.duration.value/urlAsset.duration.timescale);
    
    AVAssetImageGenerator *generator = [AVAssetImageGenerator assetImageGeneratorWithAsset: urlAsset];
    generator.appliesPreferredTrackTransform = YES;
    generator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    generator.maximumSize = CGSizeMake(360, 480);
    
    NSError *error = nil;
    CGImageRef img = [generator copyCGImageAtTime: CMTimeMake(10, 10) actualTime:NULL error:&error];
    
    if (error) {
        NSLog(@"Error happened: %@", [error description]);
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage: img];
    CGImageRelease(img);
    
    return image;
    
}

@end
