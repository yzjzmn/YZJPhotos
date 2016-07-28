//
//  YZJPhotoList.m
//  youngcity
//
//  Created by yzj on 16/7/20.
//  Copyright © 2016年 Zhitian Network Tech. All rights reserved.
//

#import "YZJPhotoList.h"
#import "YZJPhotosTool.h"
#import "YZJThumbnailController.h"
#import "YZJPhotoListCell.h"

@interface YZJPhotoList ()
{
    NSMutableArray *_arrayDataSources;
}
@end

@implementation YZJPhotoList

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeTop;
    
    self.title = @"照片";
    
    _arrayDataSources = [@[] mutableCopy];
    
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    [self initNavBtn];
    [self loadAblums];
    [self pushAllPhotoSoon];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)navRightBtn_Click
{
    if (self.CancelBlock) {
        self.CancelBlock();
    }
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
    self.navigationItem.hidesBackButton = YES;
}

#pragma mark - 加载所有相册列表
- (void)loadAblums
{
    [_arrayDataSources addObjectsFromArray:[[YZJPhotosTool sharePhotoTool] getPhotoAblumList]];
}

#pragma mark - 直接push到所有照片界面
- (void)pushAllPhotoSoon
{
    NSInteger i = 0;
    for (YZJPhotosAblumList *ablum in _arrayDataSources) {
        if (ablum.assetCollection.assetCollectionSubtype == 209 || [ablum.title isEqualToString:@"所有照片"]) {
            i = [_arrayDataSources indexOfObject:ablum];
            break;
        }
    }
    [self pushThumbnailVCWithIndex:i animated:NO];
}

- (void)pushThumbnailVCWithIndex:(NSInteger)index animated:(BOOL)animated
{
    YZJPhotosAblumList *ablum = _arrayDataSources[index];
    
    YZJThumbnailController *tvc = [[YZJThumbnailController alloc] initWithNibName:@"YZJThumbnailController" bundle:[NSBundle bundleForClass:self.class]];
    tvc.title = ablum.title;
    tvc.maxSelectCount = self.maxSelectCount;
    tvc.assetCollection = ablum.assetCollection;
    tvc.arraySelectPhotos = self.arraySelectPhotos.mutableCopy;
    tvc.sender = self;
    tvc.DoneBlock = self.DoneBlock;
    tvc.CancelBlock = self.CancelBlock;
    [self.navigationController pushViewController:tvc animated:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _arrayDataSources.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YZJPhotoListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YZJPhotoListCell"];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"YZJPhotoListCell" owner:self options:nil] lastObject];
    }
    
    YZJPhotosAblumList *ablumList= _arrayDataSources[indexPath.row];
    
    [[YZJPhotosTool sharePhotoTool] requestImageForAsset:ablumList.headImageAsset size:CGSizeMake(65*3, 65*3) resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image, NSDictionary *info) {
        cell.headImageView.image = image;
    }];
    cell.titleLabel.text = [NSString stringWithFormat:@"%@  (%ld)", ablumList.title, ablumList.count];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self pushThumbnailVCWithIndex:indexPath.row animated:YES];
}


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
