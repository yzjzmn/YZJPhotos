//
//  YZJCollectionCell.m
//  youngcity
//
//  Created by yzj on 16/7/21.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import "YZJCollectionCell.h"
#import <Photos/Photos.h>
#import "YZJPhotosTool.h"
#import "YZJSelectPhotoModel.h"
#import "YZJDefine.h"



@interface YZJCollectionCell ()

{
    NSMutableArray *selectPhotos;
}

@property (nonatomic, copy) selectBlock selectBlock;

@end

@implementation YZJCollectionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [_selectBtn setImage:[UIImage imageNamed:@"btn_selected"] forState:UIControlStateSelected];
    
}
- (IBAction)selectBtn_Click:(UIButton *)sender {
    
    if (selectPhotos.count >= 9) {
        NSLog(@"不能超过9张");
        return;
    }
    
    sender.selected = !sender.selected;
    
    [sender.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    
    if (_selectBlock) {
        _selectBlock(sender.selected);
    }
    
}

- (void)setPhAsset:(PHAsset *)asset about:(NSMutableArray *)arraySelectPhotos select:(selectBlock)block
{
    _selectBlock = block;
    selectPhotos = arraySelectPhotos;
    WEAKSELF
//    CGFloat assetW = asset.pixelWidth;
//    CGFloat assetH = asset.pixelHeight;
//    CGSize size = CGSizeMake(assetW, assetH);
    //(这里不建议取原尺寸加载,会造成内存瞬间增高,取当前控件的3倍即可)
    CGSize size = self.frame.size;
    size.width *= 2;
    size.height *= 2;
    
    [[YZJPhotosTool sharePhotoTool] requestImageForAsset:asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.imageView.image = image;
        
        for (YZJSelectPhotoModel *model in arraySelectPhotos) {
            if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
                _selectBtn.selected = YES;
                break;
            }
        }
    }];
}

@end
