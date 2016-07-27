//
//  PhotoView.m
//  YZJPhotos
//
//  Created by yzj on 16/7/26.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import "PhotoView.h"
#import <Photos/Photos.h>

@interface PhotoView ()
{
    __weak IBOutlet UIImageView *imageView;
    __weak IBOutlet UIButton *delBtn;
}


@end

@implementation PhotoView

- (void)initWithTarget:(id)target panAction:(SEL)pan delAction:(SEL)del asset:(PHAsset *)newAsset
{
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:target action:pan];
    
    [self addGestureRecognizer:panGestureRecognizer];
    
    [delBtn addTarget:target action:del forControlEvents:UIControlEventTouchUpInside];
    
    _phAsset = newAsset;
    
    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
    
    //同步获取图片,只会返回1张图
    options.synchronous = YES;
    options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [[PHImageManager defaultManager] requestImageForAsset:newAsset targetSize:CGSizeMake(kScreenWidth - 30, kScreenHeight) contentMode:PHImageContentModeAspectFit options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        
        //设置图片
        [imageView setImage:result];
        
    }];
}


@end
