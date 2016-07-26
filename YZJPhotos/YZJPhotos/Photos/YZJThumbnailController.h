//
//  YZJThumbnailController.h
//  youngcity
//
//  Created by yzj on 16/7/21.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAssetCollection;
@class YZJPhotoList;
@class YZJSelectPhotoModel;

@interface YZJThumbnailController : UIViewController

//相册属性
@property (nonatomic, strong) PHAssetCollection *assetCollection;

//当前已经选择的图片
@property (nonatomic, strong) NSMutableArray<YZJSelectPhotoModel *> *arraySelectPhotos;

//最大选择数
@property (nonatomic, assign) NSInteger maxSelectCount;
//是否选择了原图
@property (nonatomic, assign) BOOL isSelectOriginalPhoto;

//用于回调上级列表，把已选择的图片传回去
@property (nonatomic, weak) YZJPhotoList *sender;

//选则完成后回调
@property (nonatomic, copy) void (^DoneBlock)(NSArray<YZJSelectPhotoModel *> *selPhotoModels, BOOL isSelectOriginalPhoto);
//取消选择后回调
@property (nonatomic, copy) void (^CancelBlock)();


@end
