//
//  DownloadModel.h
//  RYFDownLoadManager
//
//  Created by 任玉飞 on 16/6/20.
//  Copyright © 2016年 任玉飞. All rights reserved.

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger,DownloadState){
    DownloadStateStart = 0,     /** 下载中 */
    DownloadStateSuspended,     /** 下载暂停 */
    DownloadStateCompleted,     /** 下载完成 */
    DownloadStateFailed         /** 下载失败 */
};

typedef void(^RYFDownloadProgressVlock)(CGFloat progress, NSString *speed, NSString *remainingTime, NSString *writtenSize, NSString *totalSize);
typedef void(^RYFDownloadStateBlock)(DownloadState state);

@interface DownloadModel : NSObject <NSCoding>

@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *fileName;
@property (nonatomic, copy) NSString *totalSize;
@property (nonatomic, assign) NSInteger totalLength;
@property (nonatomic, copy) RYFDownloadStateBlock stateBlock;
@property (nonatomic, copy) RYFDownloadProgressVlock progressBlock;
@property (nonatomic, strong) NSOutputStream *stream;
@end
