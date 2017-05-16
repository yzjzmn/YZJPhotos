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
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectCell)];
    [self addGestureRecognizer:tap];
    
}

- (void)selectCell
{
    if (selectPhotos.count >= 9) {
        NSLog(@"不能超过9张");
        return;
    }
    _selectBtn.selected = !_selectBtn.selected;
    
    [_selectBtn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
    
    if (_selectBlock) {
        _selectBlock(_selectBtn.selected);
    }
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

- (void)setModel:(YZJSelectPhotoModel *)model about:(NSMutableArray *)arraySelectPhotos select:(selectBlock)block
{
    _selectBlock = block;
    selectPhotos = arraySelectPhotos;
    WEAKSELF
//    CGFloat assetW = asset.pixelWidth;
//    CGFloat assetH = asset.pixelHeight;
//    CGSize size = CGSizeMake(assetW, assetH);
    //(这里不建议取原尺寸加载,会造成内存瞬间增高,取当前控件的3倍即可)
    CGSize size = self.frame.size;
    size.width *= 3;
    size.height *= 3;
    
    [[YZJPhotosTool sharePhotoTool] requestImageForAsset:model.asset size:size resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image, NSDictionary *info) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        strongSelf.imageView.image = image;
        
        NSMutableArray *indArr = [@[] mutableCopy];
        for (YZJSelectPhotoModel *theModel in arraySelectPhotos) {
            
            [indArr addObject:theModel.localIdentifier];
            
        }
        
        if ([indArr containsObject:model.localIdentifier]) {
            _selectBtn.selected = YES;
        }
        
    }];
}


@end
