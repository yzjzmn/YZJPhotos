//
//  PhotoView.h
//  YZJPhotos
//
//  Created by yzj on 16/7/26.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset, YZJSelectPhotoModel;

@interface PhotoView : UIView

- (void)initWithTarget:(id)target panAction:(SEL)pan delAction:(SEL)del model:(YZJSelectPhotoModel *)newModel;

@property (nonatomic, strong) YZJSelectPhotoModel *model;

@end
