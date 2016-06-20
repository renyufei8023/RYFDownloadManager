//
//  ViewController.m
//  RYFDownLoadManager
//
//  Created by 任玉飞 on 16/6/20.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import "ViewController.h"
#import "DownloadModel.h"
#import "RYFDownLoadManager.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RYFDownLoadManager *download = [RYFDownLoadManager shareInstance];
    [download downloadWithUrl:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4" progress:^(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize) {
        NSLog(@"----%f",progress);
    } downloadState:^(DownloadState state) {
        NSLog(@"--------%ld",(long)state);
    }];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
