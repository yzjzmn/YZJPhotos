//
//  YZJCollectionCell.h
//  youngcity
//
//  Created by yzj on 16/7/21.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PHAsset, YZJSelectPhotoModel;

typedef void(^selectBlock)(BOOL isSelect);

@interface YZJCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIButton *selectBtn;

- (void)setModel:(YZJSelectPhotoModel *)model about:(NSMutableArray *)arraySelectPhotos select:(selectBlock)block;

@end
