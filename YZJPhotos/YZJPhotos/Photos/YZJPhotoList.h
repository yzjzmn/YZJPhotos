//
//  YZJPhotoList.h
//  youngcity
//
//  Created by yzj on 16/7/20.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YZJSelectPhotoModel;

@interface YZJPhotoList : UITableViewController

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray *arraySelectPhotos;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<YZJSelectPhotoModel *> *selPhotoModels);

//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();

@end
