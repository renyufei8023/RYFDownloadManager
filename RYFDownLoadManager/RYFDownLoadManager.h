//
//  RYFDownLoadManager.h
//  RYFDownLoadManager
//
//  Created by 任玉飞 on 16/6/20.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DownloadModel.h"

@interface RYFDownLoadManager : NSObject

/** 保存所有下载相关信息字典 */
@property (nonatomic, strong) NSMutableDictionary *sessionModels;
/** 所有本地存储的所有下载信息数据数组 */
@property (nonatomic, strong) NSMutableArray *sessionModelsArray;
/** 下载完成的模型数组*/
@property (nonatomic, strong) NSMutableArray *downloadedArray;
/** 下载中的模型数组*/
@property (nonatomic, strong) NSMutableArray *downloadingArray;

+ (instancetype)shareInstance;

- (void)downloadWithUrl:(NSString *)url progress:(RYFDownloadProgressVlock)progressBlock downloadState:(RYFDownloadStateBlock)stateBlock;

@end
