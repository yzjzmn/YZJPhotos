//
//  YZJPreviewController.h
//  YZJPhotos
//
//  Created by yzj on 16/7/26.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>

@class YZJSelectPhotoModel;

@interface YZJPreviewController : UIViewController

@property (nonatomic, strong) NSArray<PHAsset *> *assets;

@property (nonatomic, strong) NSMutableArray<YZJSelectPhotoModel *> *arraySelectPhotos;

@property (nonatomic, assign) NSInteger selectIndex; //选中的图片下标

@property (nonatomic, assign) NSInteger maxSelectCount; //最大选择照片数

@property (nonatomic, assign) BOOL isPresent; //该界面显示方式，预览界面查看大图进来是present，从相册小图进来是push

@property (nonatomic, assign) BOOL shouldReverseAssets; //是否需要对接收到的图片数组进行逆序排列

@property (nonatomic, copy) void (^onSelectedPhotos)(NSArray<YZJSelectPhotoModel *> *selectPhotos); //点击返回按钮的回调

@property (nonatomic, copy) void (^btnDoneBlock)(NSArray<YZJSelectPhotoModel *> *selectPhotos); //点击确定按钮回调


@end
