//
//  RYFDownLoadManager.m
//  RYFDownLoadManager
//
//  Created by 任玉飞 on 16/6/20.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

// 缓存主目录
#define RYFCachesDirectory [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject]stringByAppendingPathComponent:@"RYFCache"]

// 保存文件名
#define RYFFileName(url)  [[url componentsSeparatedByString:@"/"] lastObject]

// 文件的存放路径（caches）
#define RYFFileFullpath(url) [RYFCachesDirectory stringByAppendingPathComponent:RYFFileName(url)]

// 文件的已下载长度
#define RYFDownloadLength(url) [[[NSFileManager defaultManager] attributesOfItemAtPath:RYFFileFullpath(url) error:nil][NSFileSize] integerValue]

// 存储文件信息的路径（caches）
#define RYFDownloadDetailPath [RYFCachesDirectory stringByAppendingPathComponent:@"downloadDetail.data"]

#import "RYFDownLoadManager.h"
#import "DownloadModel.h"

@interface RYFDownLoadManager ()<NSURLSessionDataDelegate>
/** 保存所有任务(注：用下载地址/后作为key) */
@property (nonatomic, strong) NSMutableDictionary *tasks;

@end

@implementation RYFDownLoadManager

- (NSMutableDictionary *)tasks
{
    if (!_tasks) {
        _tasks = [NSMutableDictionary dictionary];
    }
    return _tasks;
}

- (NSMutableDictionary *)sessionModels
{
    if (!_sessionModels) {
        _sessionModels = @{}.mutableCopy;
    }
    return _sessionModels;
}

- (NSMutableArray *)sessionModelsArray
{
    if (!_sessionModelsArray) {
        _sessionModelsArray = @[].mutableCopy;
        [_sessionModelsArray addObjectsFromArray:[self getDownloadModel]];
    }
    return _sessionModelsArray;
}

- (NSMutableArray *)downloadedArray
{
    if (!_downloadedArray) {
        _downloadedArray = @[].mutableCopy;
        for (DownloadModel *model in self.sessionModelsArray) {
            if ([self isCompleted:model.url]) {
                [_downloadedArray addObject:model];
            }
        }
    }
    return _downloadedArray;
}

- (NSMutableArray *)downloadingArray
{
    if (!_downloadingArray) {
        _downloadingArray = @[].mutableCopy;
        for (DownloadModel *model in self.sessionModelsArray) {
            if (![self isCompleted:model.url]) {
                [_downloadedArray addObject:model];
            }
        }
    }
    return _downloadingArray;
}

static RYFDownLoadManager *_downloader = nil;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _downloader = [[self alloc]init];
    });
    return _downloader;
}

/**
 *  归档
 *
 *  @param models <#models description#>
 */
- (void)save:(NSArray *)models
{
    [NSKeyedArchiver archiveRootObject:models toFile:RYFDownloadDetailPath];
}

/**
 *  从沙盒中获取模型数组
 *
 *  @return <#return value description#>
 */
- (NSArray *)getDownloadModel
{
    NSArray *models = [NSKeyedUnarchiver unarchiveObjectWithFile:RYFDownloadDetailPath];
    return models;
}

- (BOOL)isCompleted:(NSString *)url
{
    if ([self fileTotalLength:url] && RYFDownloadLength(url) == [self fileTotalLength:url]) {
        return YES;
    }
    return NO;
}

- (NSInteger)fileTotalLength:(NSString *)url
{
    for (DownloadModel *model in self.sessionModelsArray) {
        if ([model.url isEqualToString:url]) {
            return model.totalLength;
        }
    }
    return 0;
}

- (void)downloadWithUrl:(NSString *)url progress:(RYFDownloadProgressVlock)progressBlock downloadState:(RYFDownloadStateBlock)stateBlock
{
    if (!url) {
        return;
    }
    
    if ([self isCompleted:url]) {
        stateBlock(DownloadStateCompleted);
        return;
    }
    
    if ([self.tasks valueForKey:RYFFileName(url)]) {
        [self handle:url];
        return;
    }
    
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:RYFCachesDirectory]) {
        [manager createDirectoryAtPath:RYFCachesDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
    }
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[[NSOperationQueue alloc]init]];
    
    NSOutputStream *stream  =[NSOutputStream outputStreamToFileAtPath:RYFFileFullpath(url) append:YES];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSString *header = [NSString stringWithFormat:@"bytes=%zd-", RYFDownloadLength(url)];
    [request setValue:header forHTTPHeaderField:@"Range"];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request];
    NSUInteger taskIdentifier = arc4random() % ((arc4random() % 10000 + arc4random() % 10000));
    [task setValue:@(taskIdentifier) forKeyPath:@"taskIdentifier"];
    
    [self.tasks setValue:task forKey:RYFFileName(url)];
    
    if (![manager fileExistsAtPath:RYFFileFullpath(url)]) {
        DownloadModel *mode = [[DownloadModel alloc]init];
        mode.url = url;
        mode.progressBlock = progressBlock;
        mode.stateBlock = stateBlock;
        mode.stream = stream;
        mode.fileName = RYFFileName(url);
        [self.sessionModels setValue:mode forKey:@(task.taskIdentifier).stringValue];
        [self.sessionModelsArray addObject:mode];
        [self.downloadingArray addObject:mode];
        // 保存
        [self save:self.sessionModelsArray];

    }else{
        for (DownloadModel *model in self.sessionModelsArray) {
            if ([model.url isEqualToString:url]) {
                model.url = url;
                model.progressBlock = progressBlock;
                model.stateBlock = stateBlock;
                model.stream = stream;
                model.fileName = RYFFileName(url);
                [self.sessionModels setValue:model forKey:@(task.taskIdentifier).stringValue];
            }
        }
    }
    
    [self start:url];
}

- (void)handle:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    if (task.state == NSURLSessionTaskStateRunning) {
        [self pause:url];
    }else{
        [self start:url];
    }
}

- (NSURLSessionDataTask *)getTask:(NSString *)url
{
    return (NSURLSessionDataTask *)[self.tasks objectForKey:RYFFileName(url)];
}

- (void)pause:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task suspend];
    [self getModel:task.taskIdentifier].stateBlock(DownloadStateStart);
}

- (void)start:(NSString *)url
{
    NSURLSessionDataTask *task = [self getTask:url];
    [task resume];
    [self getModel:task.taskIdentifier].stateBlock(DownloadStateSuspended);
}

- (DownloadModel *)getModel:(NSUInteger)taskIdentifier
{
    return (DownloadModel *)[self.sessionModels valueForKey:@(taskIdentifier).stringValue];
}

- (CGFloat)progress:(NSString *)url
{
    return [self fileTotalLength:url] == 0 ? 0.0 : 1.0 * RYFDownloadLength(url) /  [self fileTotalLength:url];
}

#pragma mark NSURLSessionDataDelegate

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSHTTPURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    DownloadModel *model = [self getModel:dataTask.taskIdentifier];
    
    [model.stream open];
    
    NSInteger totalLength = [response.allHeaderFields[@"Content-Length"] integerValue] + RYFDownloadLength(model.url);
    model.totalLength = totalLength;
    
    [self save:self.sessionModelsArray];
    
    if (![self.downloadingArray containsObject:model]) {
        [self.downloadingArray addObject:model];
    }
    
    completionHandler(NSURLSessionResponseAllow);
}

- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
    DownloadModel *model = [self getModel:dataTask.taskIdentifier];
    
    // 写入数据
    [model.stream write:data.bytes maxLength:data.length];
    
    // 下载进度
    NSUInteger receivedSize = RYFDownloadLength(model.url);
    NSUInteger expectedSize = model.totalLength;
    CGFloat progress = 1.0 * receivedSize / expectedSize;
    
    
    
    if (model.stateBlock) {
        model.stateBlock(DownloadStateStart);
    }
    if (model.progressBlock) {
        model.progressBlock(progress, nil, nil,nil, nil);
    }

}

- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    DownloadModel *model = [self getModel:task.taskIdentifier];
    if (!model) {
        return;
    }
    [model.stream close];
    model.stream = nil;
    
    
    if ([self isCompleted:model.url]) {
        // 下载完成
        model.stateBlock(DownloadStateCompleted);
    } else if (error){
        // 下载失败
        model.stateBlock(DownloadStateFailed);
    }
    // 清除任务
    [self.tasks removeObjectForKey:RYFFileName(model.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    [self.downloadingArray removeObject:model];
    
    // 清除任务
    [self.tasks removeObjectForKey:RYFFileName(model.url)];
    [self.sessionModels removeObjectForKey:@(task.taskIdentifier).stringValue];
    
    [self.downloadingArray removeObject:model];
    
    if (error.code == -999)    return;   // cancel
    
    if (![self.downloadedArray containsObject:model]) {
        [self.downloadedArray addObject:model];
    }

}
@end
