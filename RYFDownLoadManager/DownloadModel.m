//
//  DownloadModel.m
//  RYFDownLoadManager
//
//  Created by 任玉飞 on 16/6/20.
//  Copyright © 2016年 任玉飞. All rights reserved.
//

#import "DownloadModel.h"

@implementation DownloadModel

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.url forKey:@"url"];
    [aCoder encodeObject:self.fileName forKey:@"fileName"];
    [aCoder encodeObject:self.totalSize forKey:@"totalSize"];
    [aCoder encodeInteger:self.totalLength forKey:@"totalLength"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.fileName = [aDecoder decodeObjectForKey:@"fileName"];
        self.totalLength = [aDecoder decodeIntegerForKey:@"totalLength"];
        self.totalSize = [aDecoder decodeObjectForKey:@"totalSize"];
    }
    return self;
}
@end
