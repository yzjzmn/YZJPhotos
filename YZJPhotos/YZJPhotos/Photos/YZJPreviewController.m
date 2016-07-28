//
//  YZJPreviewController.m
//  YZJPhotos
//
//  Created by yzj on 16/7/26.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import "YZJPreviewController.h"
#import "YZJDefine.h"
#import "YZJSelectPhotoModel.h"
#import "YZJPreviewCell.h"
#import "YZJPhotosTool.h"

@interface YZJPreviewController ()<UICollectionViewDelegate, UICollectionViewDataSource>
{
    
    UICollectionView *_collectionView;
    
    NSMutableArray<PHAsset *> *_arrayDataSources;
    UIButton *_navRightBtn;
    
    //底部view
    UIView   *_bottomView;
    UIButton *_btnOriginalPhoto;
    UIButton *_btnDone;
    
    //双击的scrollView
    UIScrollView *_selectScrollView;
    NSInteger _currentPage;
    
}
@end

@implementation YZJPreviewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [self initNavBtns];
    [self sortAsset];
    [self initCollectionView];
    [self initBottomView];
    [self changeBtnDoneTitle];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.shouldReverseAssets) {
        [_collectionView setContentOffset:CGPointMake((self.assets.count-self.selectIndex-1)*(kScreenWidth+kItemMargin), 0)];
    } else {
        [_collectionView setContentOffset:CGPointMake(self.selectIndex*(kScreenWidth+kItemMargin), 0)];
    }
    
    [self changeNavRightBtnStatus];
}

- (void)initNavBtns
{
    //left nav btn
    UIImage *navBackImg = [UIImage imageNamed:@"navibar_back_gray"];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(btnBack_Click)];
    
    //right nav btn
    _navRightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _navRightBtn.frame = CGRectMake(0, 0, 25, 25);
    UIImage *normalImg = [UIImage imageNamed:@"btn_original_circle"];
    UIImage *selImg = [UIImage imageNamed:@"btn_selected"];
    
    [_navRightBtn setBackgroundImage:normalImg forState:UIControlStateNormal];
    [_navRightBtn setBackgroundImage:selImg forState:UIControlStateSelected];
    [_navRightBtn addTarget:self action:@selector(navRightBtn_Click:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:_navRightBtn];
}

- (void)sortAsset
{
    _arrayDataSources = [NSMutableArray array];
    if (self.shouldReverseAssets) {
        NSEnumerator *enumerator = [self.assets reverseObjectEnumerator];
        id obj;
        while (obj = [enumerator nextObject]) {
            [_arrayDataSources addObject:obj];
        }
        //当前页
        _currentPage = _arrayDataSources.count-self.selectIndex;
    } else {
        [_arrayDataSources addObjectsFromArray:self.assets];
        _currentPage = self.selectIndex + 1;
    }
    self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
}

#pragma mark - 初始化CollectionView
- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.minimumLineSpacing = kItemMargin;
    layout.sectionInset = UIEdgeInsetsMake(0, kItemMargin/2, 0, kItemMargin/2);
    layout.itemSize = self.view.bounds.size;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(-kItemMargin/2, 0, kScreenWidth+kItemMargin, kScreenHeight) collectionViewLayout:layout];
    
    //注册 cell
    [_collectionView registerClass:[YZJPreviewCell class] forCellWithReuseIdentifier:@"YZJPreviewCell"];
    
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    [self.view addSubview:_collectionView];
}

- (void)initBottomView
{
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 44, kScreenWidth, 44)];
    _bottomView.backgroundColor = [UIColor whiteColor];
    
    _btnOriginalPhoto = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnOriginalPhoto.frame = CGRectMake(12, 7, 60, 30);
    [_btnOriginalPhoto setTitle:@"原图" forState:UIControlStateNormal];
    _btnOriginalPhoto.titleLabel.font = [UIFont systemFontOfSize:15];
    [_btnOriginalPhoto setTitleColor:UIColorFromRGB(0x50b4ea) forState: UIControlStateNormal];
    [_btnOriginalPhoto setTitleColor:UIColorFromRGB(0x50b4ea) forState: UIControlStateSelected];
    UIImage *normalImg = [UIImage imageNamed:@"btn_original_circle"];
    UIImage *selImg = [UIImage imageNamed:@"btn_selected"];
    [_btnOriginalPhoto setImage:normalImg forState:UIControlStateNormal];
    [_btnOriginalPhoto setImage:selImg forState:UIControlStateSelected];
    [_btnOriginalPhoto setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 5)];
    [_btnOriginalPhoto addTarget:self action:@selector(btnOriginalImage_Click:) forControlEvents:UIControlEventTouchUpInside];
    
    [_bottomView addSubview:_btnOriginalPhoto];
    
    _btnDone = [UIButton buttonWithType:UIButtonTypeCustom];
    _btnDone.frame = CGRectMake(kScreenWidth - 82, 7, 70, 30);
    [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    _btnDone.titleLabel.font = [UIFont systemFontOfSize:15];
    _btnDone.layer.masksToBounds = YES;
    _btnDone.layer.cornerRadius = 3.0f;
    [_btnDone setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnDone setBackgroundColor:UIColorFromRGB(0x50b4ea)];
    [_btnDone addTarget:self action:@selector(btnDone_Click:) forControlEvents:UIControlEventTouchUpInside];
    [_bottomView addSubview:_btnDone];
    
    [self.view addSubview:_bottomView];
}

#pragma mark - UIButton Actions
- (void)btnDone_Click:(UIButton *)btn
{
    if (self.arraySelectPhotos.count == 0) {
        PHAsset *asset = _arrayDataSources[_currentPage-1];
        if (![[YZJPhotosTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            //(@"图片加载中，请稍后");
            return;
        }
        YZJSelectPhotoModel *model = [[YZJSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    }
    if (self.btnDoneBlock) {
        self.btnDoneBlock(self.arraySelectPhotos);
    }
}

- (void)btnBack_Click
{
    if (self.onSelectedPhotos) {
        self.onSelectedPhotos(self.arraySelectPhotos);
    }
    
    if (self.isPresent) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        //由于collectionView的frame的width是大于该界面的width，所以设置这个颜色是为了pop时候隐藏collectionView的黑色背景
        _collectionView.backgroundColor = [UIColor clearColor];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)navRightBtn_Click:(UIButton *)btn
{
    if (_arraySelectPhotos.count >= self.maxSelectCount
        && btn.selected == NO) {
        //(@"最多只能选择%ld张图片", self.maxSelectCount);
        return;
    }
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    if (![self isHaveCurrentPageImage]) {
        [btn.layer addAnimation:GetBtnStatusChangedAnimation() forKey:nil];
        
        if (![[YZJPhotosTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
            //(@"图片加载中，请稍后");
            return;
        }
        YZJSelectPhotoModel *model = [[YZJSelectPhotoModel alloc] init];
        model.asset = asset;
        model.localIdentifier = asset.localIdentifier;
        [_arraySelectPhotos addObject:model];
    } else {
        [self removeCurrentPageImage];
    }
    
    btn.selected = !btn.selected;
    [self changeBtnDoneTitle];
}

- (void)removeCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (YZJSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            [_arraySelectPhotos removeObject:model];
            break;
        }
    }
}


#pragma mark - 更新按钮、导航条等显示状态
- (void)changeNavRightBtnStatus
{
    if ([self isHaveCurrentPageImage]) {
        _navRightBtn.selected = YES;
    } else {
        _navRightBtn.selected = NO;
    }
}

- (void)changeBtnDoneTitle
{
    if (self.arraySelectPhotos.count > 0) {
        [_btnDone setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
    } else {
        [_btnDone setTitle:@"确定" forState:UIControlStateNormal];
    }
}


- (BOOL)isHaveCurrentPageImage
{
    PHAsset *asset = _arrayDataSources[_currentPage-1];
    for (YZJSelectPhotoModel *model in _arraySelectPhotos) {
        if ([model.localIdentifier isEqualToString:asset.localIdentifier]) {
            return YES;
        }
    }
    return NO;
}

- (void)hideNavBarAndBottomView:(BOOL)isShow
{
    self.navigationController.navigationBar.hidden = isShow;
    [UIApplication sharedApplication].statusBarHidden = isShow;
    _bottomView.hidden = isShow;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataSources.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    YZJPreviewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YZJPreviewCell" forIndexPath:indexPath];
    
    PHAsset *asset = _arrayDataSources[indexPath.row];
    
    cell.asset = asset;
    WEAKSELF
    cell.singleTapCallBack = ^() {
        if (weakSelf.navigationController.navigationBar.isHidden) {
            [weakSelf hideNavBarAndBottomView:NO];
        } else {
            [weakSelf hideNavBarAndBottomView:YES];
        }
    };
    
    return cell;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == (UIScrollView *)_collectionView) {
        //改变导航标题
        CGFloat page = scrollView.contentOffset.x/(kScreenWidth+kItemMargin);
        NSString *str = [NSString stringWithFormat:@"%.0f", page];
        _currentPage = str.integerValue + 1;
        self.title = [NSString stringWithFormat:@"%ld/%ld", _currentPage, _arrayDataSources.count];
        [self changeNavRightBtnStatus];
    }
}



@end
