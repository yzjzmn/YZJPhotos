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
    self.doneBtn.layer.cornerRadius = 3.0f;
    
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
    self.sender.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
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
        self.DoneBlock(self.arraySelectPhotos, self.isSelectOriginalPhoto);
    }
}
- (IBAction)previewBtn_Click:(id)sender {
    self.sender.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    self.sender.isSelectOriginalPhoto = self.isSelectOriginalPhoto;
    [self.navigationController popViewControllerAnimated:YES];
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
    PHAsset *asset = _arrayDataSources[assetIndex];
    
    YZJSelectPhotoModel *model = [[YZJSelectPhotoModel alloc] init];
    model.asset = asset;
    model.localIdentifier = asset.localIdentifier;
    WEAKSELF
    [cell setPhAsset:asset about:_arraySelectPhotos select:^(BOOL isSelect) {
        NSLog(@"%i", isSelect);
        if (isSelect) {
            
            [weakSelf.arraySelectPhotos addObject:model];
            
        } else {
            [weakSelf.arraySelectPhotos removeObject:model];
        }
        
        [weakSelf controlBottomBtnsStatus];
    }];
    
    return cell;
    
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        
        if (![self judgeIsHaveCameraAuthority]) {
            //无相册访问权限
            
        } else {
            __weak typeof(self) weakSelf = self;

            if (_arraySelectPhotos.count >= self.maxSelectCount) {
//                ShowToastLong(@"最多只能选择%ld张图片", self.maxSelectCount);
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
    } else {
        
        //点击预览了
        
    }
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
//        ShowToastLong(@"该图片尚未从iCloud下载，请在系统相册中下载到本地后重新尝试，或在预览大图中加载完毕后选择");
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