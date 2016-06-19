//
//  AbilityDetailViewController.m
//  Dota2Heropedia
//
//  Created by shouzhi on 16/6/6.
//  Copyright © 2016年 shouzhi. All rights reserved.
//

#import "AbilityDetailViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <AVFoundation/AVFoundation.h>
//#import <QuartzCore/QuartzCore.h>


@interface AbilityDetailViewController ()

@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic) AVPlayerItem *playerItem;

@property (nonatomic) BOOL isPlaying;

@property (nonatomic) UIButton *playButton;
@property (nonatomic, assign) UILabel *timeLable;

@property (nonatomic) NSInteger totalTime;
@property (nonatomic) NSInteger currentTime;


@property (weak, nonatomic) IBOutlet UIView *headView;
@property (weak, nonatomic) IBOutlet UIView *introView;
@property (weak, nonatomic) IBOutlet UIView *videoView;

@property (weak, nonatomic) IBOutlet UIImageView *headImage;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;


@end

@implementation AbilityDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
//    self.abilityName = @"antimage_mana_break";
//    NSString *docPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
//    NSDictionary *heroesAbility = [NSDictionary dictionaryWithContentsOfFile:[docPath stringByAppendingPathComponent:@"heroesAbility.plist"]];
//    self.hero = [heroesAbility objectForKey:self.abilityName];//antimage_mana_break
    //NSLog(@"%@", self.hero);

    self.title = [self.hero objectForKey:@"dname"];

    [self setHeadInfo];
    [self setIntroInfo];
    [self setVideoInfo];

}

//-(void)viewWillAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
////    [self.view bringSubviewToFront:self.videoView];
////    [self.videoView bringSubviewToFront:self.playButton];
////    [self.view setUserInteractionEnabled:YES];
////    [self.videoView setUserInteractionEnabled:YES];
////    [self.timeLable setUserInteractionEnabled:NO];
////    [self.playButton setUserInteractionEnabled:YES];
//}

-(void)setHeadInfo {
    [self.headImage sd_setImageWithURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://cdn.dota2.com/apps/dota2/images/abilities/%@_hp2.png", self.abilityName] ] ];
    
    NSString *descText = [[self.hero objectForKey:@"desc"] stringByReplacingOccurrencesOfString:@"\r\n" withString:@" "];
    self.descLabel.attributedText = [self setAttributedString:descText fotHeight:4];
    self.descLabel.numberOfLines = 0;
    [self.descLabel sizeToFit];
}

- (void)setIntroInfo {
    CGRect frame = [[UIScreen mainScreen] bounds]; //获取当前屏幕
    UIFont *commonFont = [UIFont fontWithName:@"HelveticaNeue-Light" size:15];
    
    //设置行高
    NSString *noteString = [[self.hero objectForKey:@"notes"] stringByReplacingOccurrencesOfString:@"<br />" withString:@" "];
    
    UILabel *noteLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 8, frame.size.width-16, 40)];
    noteLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    noteLabel.attributedText = [self setAttributedString:noteString fotHeight:5];
    noteLabel.numberOfLines = 0;
    [noteLabel sizeToFit];
    [self.introView addSubview:noteLabel];
    
    ////处理左半边的affects
    //将字符串按照html标签<br/>来分割
    NSArray *affectsList = [[self.hero objectForKey:@"affects"] componentsSeparatedByString:@"<br />"];
    NSString *resultByFilter = [self filterHtml:affectsList];
    affectsList = nil;

    UILabel *affectsLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, noteLabel.frame.size.height+20, frame.size.width*0.5, 100)];
    affectsLabel.font = commonFont;
    //label.text = resultByFilter;
    affectsLabel.attributedText = [self setAttributedString:resultByFilter fotHeight:5];
    affectsLabel.numberOfLines = 0;
    [affectsLabel sizeToFit];
    [self.introView addSubview: affectsLabel];
    
    ////处理右半边的attib,和上面步骤一样
    NSArray *attribList = [[self.hero objectForKey:@"attrib"] componentsSeparatedByString:@"<br />"];
    resultByFilter = [self filterHtml:attribList]; //reuse
    attribList = nil;
    //NSLog(@"%@", resultByFilter);
    
    UILabel *attribLable = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width*0.5, noteLabel.frame.size.height+20, frame.size.width*0.5, 100)];
    attribLable.font = commonFont;
    //label.text = resultByFilter;
    attribLable.attributedText = [self setAttributedString:resultByFilter fotHeight:5];
    attribLable.numberOfLines = 0;
    [attribLable sizeToFit];
    [self.introView addSubview: attribLable];
}

- (void)setVideoInfo {
    
    //set video player
    NSString *aVideoURLName = [[self.hero objectForKey:@"hurl"] lowercaseString];
    if ([aVideoURLName containsString:@"-"]) {
        aVideoURLName = [self.abilityName stringByReplacingOccurrencesOfString:[aVideoURLName stringByReplacingOccurrencesOfString:@"-" withString:@""] withString:aVideoURLName];
        
    } else {
        aVideoURLName = self.abilityName;
    }
    
    //该视频url对大多数技能有效，但是部分链接不规则，所以会加载失败
    NSURL *url = [NSURL URLWithString: [NSString stringWithFormat: @"http://dota2.dl.wanmei.com/dota2/video/abilities/%@.mp4", aVideoURLName]];
    
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];

    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = CGRectMake(8, 0, self.view.frame.size.width-16, 300);
    [self.videoView.layer addSublayer:layer];
    [layer setBackgroundColor:[[UIColor blackColor] CGColor] ];//colorWithRed:30 green:33 blue:33 alpha:0
    
    //set description label
    UILabel *loreLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, self.view.frame.size.width-18, 50)];
    loreLabel.textColor = [UIColor grayColor];
    loreLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:12];
    loreLabel.textAlignment = NSTextAlignmentCenter; //字体对齐方式
    loreLabel.text = [NSString stringWithFormat:@"%@", [self.hero objectForKey:@"lore"] ];
    loreLabel.numberOfLines = 0;
    [loreLabel sizeToFit];
    [self.videoView addSubview:loreLabel];
    
    //set play and stop button and timeLable
    [self showPlayButton];
    [self showTimeLable];
    //添加一个观察者观察其播放时间变化状况，当dealloc的时候要移除observer
    [self.playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        NSString *new = change[NSKeyValueChangeNewKey];
        if ([new integerValue] == AVPlayerItemStatusReadyToPlay) {//视频准备播放
            self.totalTime = CMTimeGetSeconds(self.playerItem.duration);
            self.timeLable.text = [self formmatTimeToString:self.totalTime];
            
            __weak AbilityDetailViewController *weakSelf = self;
            [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 1) queue:dispatch_get_main_queue() usingBlock:^(CMTime time){
                AbilityDetailViewController *innerSelf = weakSelf;
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
            self.timeLable.text = @"加载失败";
        }
    }
}

- (NSString *)formmatTimeToString:(NSInteger)seconds {
    int hour, min, sec;
    hour = (int)(seconds / 3600);
    min = (int)((seconds % 3600) / 60);
    sec = (int)(seconds % 60);
    
    return [NSString stringWithFormat:@"%02d:%02d:%02d", hour, min, sec];
}

- (void)showPlayButton {
    self.isPlaying = NO; //初始化为未播放状态
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-20, 255, 40, 40)];
    playButton.layer.cornerRadius = playButton.bounds.size.width / 2; //no #import <QuartzCore/QuartzCore.h>
    //[playButton setTitle:@"Play" forState:UIControlStateNormal];
    //[playButton setImage:[UIImage imageNamed:@"play_128.png"] forState:UIControlStateNormal];
    [playButton setBackgroundColor:[UIColor whiteColor]];
    [playButton setBackgroundImage:[UIImage imageNamed:@"play_128.png"] forState:UIControlStateNormal];
    [playButton addTarget:self action:@selector(touchEvent) forControlEvents:UIControlEventTouchUpInside]; //触摸按钮就是播放或暂停

    [self.videoView addSubview:playButton];
    self.playButton = playButton;
    playButton = nil;
}

- (void)showTimeLable {
//    self.totalTime = ;
    
    UILabel *timeLabel = [[UILabel alloc] initWithFrame: CGRectMake(self.view.frame.size.width-8-80, 255, 100, 40)];
    timeLabel.textColor = [UIColor whiteColor];
    timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:14];
    //timeLabel.textAlignment = NSTextAlignmentLeft; //字体对齐方式
    
    timeLabel.text = @"正在加载...";
    
    [self.videoView addSubview:timeLabel];
    self.timeLable = timeLabel;
    timeLabel = nil;
}

- (void)touchEvent {
    //self.isPlaying = !self.isPlaying;
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
    CGImageRef img = [generator copyCGImageAtTime: CMTimeMake(500, 600) actualTime:NULL error:&error];
    
    if (error) {
        NSLog(@"Error happened: %@", [error description]);
        return nil;
    }
    UIImage *image = [UIImage imageWithCGImage: img];
    CGImageRelease(img);
    
    return image;
    
}

- (NSMutableAttributedString *)setAttributedString:(NSString *)src fotHeight:(NSInteger)height{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString: src];
    NSMutableParagraphStyle *para = [[NSMutableParagraphStyle alloc] init];
    para.lineSpacing = height; //行高5px
    [attr addAttribute:NSParagraphStyleAttributeName value:para range:NSMakeRange(0, [src length])];
    
    return attr;
}

- (NSString *)filterHtml:(NSArray *)srcArr {
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
    return resultByFilter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc {
    [self.playerItem removeObserver:self forKeyPath:@"status"]; //如果不移除会报错EXC_BAD_ACCESS
}

@end
