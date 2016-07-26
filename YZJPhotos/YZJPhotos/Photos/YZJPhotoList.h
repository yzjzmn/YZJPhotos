//
//  YZJPhotoList.h
//  youngcity
//
//  Created by yzj on 16/7/20.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YZJPhotoList : UITableViewController

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;
//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray *arraySelectPhotos;


//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray *selPhotoModels, BOOL isSelectOriginalPhoto);

//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();

@end
