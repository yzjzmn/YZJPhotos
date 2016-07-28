//
//  YZJPreviewCell.h
//  YZJPhotos
//
//  Created by yzj on 16/7/28.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset;

@interface YZJPreviewCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset *asset;
@property (nonatomic, copy)   void (^singleTapCallBack)();

@end
