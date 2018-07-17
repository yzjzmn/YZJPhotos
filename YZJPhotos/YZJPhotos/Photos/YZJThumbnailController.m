//
//  YZJThumbnailController.m
//  youngcity
//
//  Created by yzj on 16/7/21.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import "YZJThumbnailController.h"
#import <Photos/Photos.h>
#import "YZJPhotoList.h"
#import "TakePhotoCell.h"
#import "YZJCollectionCell.h"
#import "YZJDefine.h"
#import "YZJPhotosTool.h"
#import "YZJSelectPhotoModel.h"
#import "YZJPreviewController.h"

@interface YZJThumbnailController ()<UICollectionViewDataSource, UICollectionViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    NSMutableArray<PHAsset *> *_arrayDataSources;
    
    BOOL _isLayoutOK;
    
    TakePhotoCell *takePhotoCell;
}

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *previewBtn;

@end

@implementation YZJThumbnailController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    _arrayDataSources = [@[] mutableCopy];
    
    self.doneBtn.layer.masksToBounds = YES;
    self.doneBtn.layer.cornerRadius = kSmallCorner;
    
    self.previewBtn.layer.borderWidth = 0.5f;
    self.previewBtn.layer.masksToBounds = YES;
    self.previewBtn.layer.cornerRadius = kSmallCorner;
    self.previewBtn.layer.borderColor = UIColorFromRGB(0xe6e6e6).CGColor;
    
    [self initNavBtn];
    [self controlBottomBtnsStatus];
    [self initCollectionView];
    [self getAssetInAssetCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initNavBtn
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 40, 44);
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn setTitle:@"取消" forState:UIControlStateNormal];
    [btn setTitleColor:UIColorFromRGB(0xf64e27) forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(navRightBtn_Click) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    UIImage *navBackImg = [UIImage imageNamed:@"navibar_back_gray"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[navBackImg imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal] style:UIBarButtonItemStylePlain target:self action:@selector(navLeftBtn_Click)];
}


/**
 *  控制确定按钮的状态
 */
- (void)controlBottomBtnsStatus
{
    if (self.arraySelectPhotos.count > 0) {
        self.previewBtn.enabled = YES;
        self.doneBtn.enabled = YES;
        [self.doneBtn setTitle:[NSString stringWithFormat:@"确定(%ld)", self.arraySelectPhotos.count] forState:UIControlStateNormal];
        //色值 80, 180, 234
        [self.previewBtn setTitleColor:UIColorFromRGB(0x50b4ea) forState:UIControlStateNormal];
        self.doneBtn.backgroundColor = UIColorFromRGB(0x50b4ea);
        [self.doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    } else {
        self.previewBtn.enabled = NO;
        self.doneBtn.enabled = NO;
        [self.doneBtn setTitle:@"确定" forState:UIControlStateDisabled];
        [self.previewBtn setTitleColor:[UIColor colorWithWhite:0.7 alpha:1] forState:UIControlStateDisabled];
        self.doneBtn.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
        [self.doneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    }
}

/**
 *  初始化collectionView
 */
- (void)initCollectionView
{
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = CGSizeMake((kScreenWidth-9)/4, (kScreenWidth-9)/4);
    layout.minimumInteritemSpacing = 1.5;
    layout.minimumLineSpacing = 1.5;
    layout.sectionInset = UIEdgeInsetsMake(3, 0, 3, 0);
    
    self.collectionView.collectionViewLayout = layout;
    self.collectionView.backgroundColor = [UIColor whiteColor];
    [self.collectionView registerNib:[UINib nibWithNibName:@"YZJCollectionCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"YZJCollectionCell"];
    
    [self.collectionView registerNib:[UINib nibWithNibName:@"TakePhotoCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"TakePhotoCell"];
}

/**
 *  获取相册中所有的照片
 */
- (void)getAssetInAssetCollection
{
    [_arrayDataSources addObjectsFromArray:[[YZJPhotosTool sharePhotoTool] getAssetsInAssetCollection:self.assetCollection ascending:NO]];
}

#pragma mark - action

- (void)navLeftBtn_Click
{
    self.sender.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)doneBtn_Click:(id)sender {
    if (self.DoneBlock) {
        self.DoneBlock(self.arraySelectPhotos);
    }
}
- (IBAction)previewBtn_Click:(id)sender {
    NSMutableArray<PHAsset *> *arrSel = [NSMutableArray array];
    
    for (YZJSelectPhotoModel *model in self.arraySelectPhotos) {
        [arrSel addObject:model.asset];
    }
    [self pushShowBigImgVCWithDataArray:arrSel selectIndex:0];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _arrayDataSources.count + 1;//多一个拍照item
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        //返回一个 cell  用于拍照调用相机
        takePhotoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TakePhotoCell" forIndexPath:indexPath];
        return takePhotoCell;
    }
    
    NSInteger assetIndex = indexPath.row - 1;//indexPath.row由于第一个按钮做出调整
    YZJCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"YZJCollectionCell" forIndexPath:indexPath];
    
    if (!cell) {
        cell = (YZJCollectionCell *)[[[NSBundle mainBundle] loadNibNamed:@"YZJCollectionCell" owner:self options:nil] lastObject];
    }
    
    PHAsset *asset = _arrayDataSources[assetIndex];
    
    YZJSelectPhotoModel *model = [[YZJSelectPhotoModel alloc] init];
    model.asset = asset;
    model.localIdentifier = asset.localIdentifier;
    WEAKSELF
    [cell setModel:model about:_arraySelectPhotos select:^(BOOL isSelect) {
        NSLog(@"%i", isSelect);
        
        if (isSelect) {
            [weakSelf.arraySelectPhotos addObject:model];
            [weakSelf controlBottomBtnsStatus];
        } else {
            for (YZJSelectPhotoModel *itemModel in weakSelf.arraySelectPhotos) {
                if ([itemModel.localIdentifier isEqualToString:model.localIdentifier]) {
                    [weakSelf.arraySelectPhotos removeObject:itemModel];
                    [weakSelf controlBottomBtnsStatus];
                    return ;
                }
            }
        }
    }];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        if ([self judgeIsHaveCameraAuthority]) {
            __weak typeof(self) weakSelf = self;

            if (_arraySelectPhotos.count >= self.maxSelectCount) {
//                (@"最多只能选择%ld张图片", self.maxSelectCount);
                return;
            }
            
            UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            //图片来源:(相册 照相机 图片库)
            imagePicker.showsCameraControls = true;
            [imagePicker setAllowsEditing:YES];
            imagePicker.delegate = weakSelf;
            [self presentViewController:imagePicker animated:YES completion:^{
                
            }];
        }
        
    }
}

#pragma mark - preview action

- (void)pushShowBigImgVCWithDataArray:(NSArray<PHAsset *> *)dataArray selectIndex:(NSInteger)selectIndex
{
    YZJPreviewController *vc = [[YZJPreviewController alloc] init];
    
    vc.assets = dataArray;
    vc.arraySelectPhotos = [NSMutableArray arrayWithArray:_arraySelectPhotos];
    
    vc.maxSelectCount = kMaxSelectCnt;
    
    vc.selectIndex = selectIndex;
    vc.isPresent = YES;
    vc.shouldReverseAssets = NO;
    
    WEAKSELF
    __weak typeof(vc) weakVc  = vc;
    [vc setOnSelectedPhotos:^(NSArray<YZJSelectPhotoModel *> *selectedPhotos) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        [weakSelf.arraySelectPhotos removeAllObjects];
        [weakSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        NSLog(@"预览返回回调数组%@", weakSelf.arraySelectPhotos);
        [weakSelf.collectionView reloadData];
    }];
    
    [vc setBtnDoneBlock:^(NSArray<YZJSelectPhotoModel *> *selectedPhotos) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        __strong typeof(weakVc) strongVc = weakVc;
        [weakSelf.arraySelectPhotos removeAllObjects];
        [weakSelf.arraySelectPhotos addObjectsFromArray:selectedPhotos];
        [weakSelf requestSelPhotos:strongVc];
        NSLog(@"预览确定回调数组%@", weakSelf.arraySelectPhotos);
        [weakSelf.collectionView reloadData];
        [weakSelf controlBottomBtnsStatus];
    }];
    
    [self presentVC:vc];
    
}

#pragma mark - 请求所选择图片、回调
- (void)requestSelPhotos:(UIViewController *)vc
{
    __weak typeof(self) weakSelf = self;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:self.arraySelectPhotos.count];
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        [photos addObject:@""];
    }
    
    CGFloat scale = self.isSelectOriginalPhoto?1:[UIScreen mainScreen].scale;
    for (int i = 0; i < self.arraySelectPhotos.count; i++) {
        YZJSelectPhotoModel *model = self.arraySelectPhotos[i];
        [[YZJPhotosTool sharePhotoTool] requestImageForAsset:model.asset scale:scale resizeMode:PHImageRequestOptionsResizeModeExact completion:^(UIImage *image) {
            if (image) [photos replaceObjectAtIndex:i withObject:[weakSelf scaleImage:image]];
            
            for (id obj in photos) {
                if ([obj isKindOfClass:[NSString class]]) return;
            }
            
            [vc.navigationController dismissViewControllerAnimated:YES completion:nil];
        }];
    }
}

/**
 * @brief 这里对拿到的图片进行缩放，不然原图直接返回的话会造成内存暴涨
 */
- (UIImage *)scaleImage:(UIImage *)image
{
    CGSize size = CGSizeMake(ScalePhotoWidth, ScalePhotoWidth * image.size.height / image.size.width);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}


#pragma mark --
- (void)presentVC:(UIViewController *)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x4d4d4d)}];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:UIColorFromRGB(0xffffff)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    [self.sender presentViewController:nav animated:YES completion:nil];
}

- (UIImage *)imageWithColor:(UIColor*)color
{
    CGRect rect=CGRectMake(0,0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

#pragma mark - 判断软件是否有相册、相机访问权限
- (BOOL)judgeIsHavePhotoAblumAuthority
{
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    
    PHAsset *asset = [self createdAssets:image].firstObject;
    [_arrayDataSources insertObject:asset atIndex:0];
    
    [picker dismissViewControllerAnimated:YES completion:^{
        [_collectionView reloadData];
        [self selectCameraImage];
    }];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)selectCameraImage
{
    PHAsset *asset = _arrayDataSources[0];
    
    if (![[YZJPhotosTool sharePhotoTool] judgeAssetisInLocalAblum:asset]) {
//        (@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试，或在预览大图中加载完毕后选择");
        return;
    }
    YZJSelectPhotoModel *cameraModel = [[YZJSelectPhotoModel alloc] init];
    cameraModel.asset = asset;
    cameraModel.localIdentifier = asset.localIdentifier;
    [_arraySelectPhotos addObject:cameraModel];
    
    [self controlBottomBtnsStatus];
}

-(PHFetchResult<PHAsset *> *)createdAssets:(UIImage *)image
{
    __block NSString *createdAssetId = nil;
    // 添加图片到【相机胶卷】
    [[PHPhotoLibrary sharedPhotoLibrary] performChangesAndWait:^{
        createdAssetId = [PHAssetChangeRequest creationRequestForAssetFromImage:image].placeholderForCreatedAsset.localIdentifier;
    } error:nil];
    if (createdAssetId == nil) return nil;
    // 在保存完毕后取出图片
    return [PHAsset fetchAssetsWithLocalIdentifiers:@[createdAssetId] options:nil];
}



@end
