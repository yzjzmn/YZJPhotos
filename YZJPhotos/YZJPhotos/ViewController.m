//
//  ViewController.m
//  YZJPhotos
//
//  Created by yzj on 16/7/26.
//  Copyright © 2016年 com.photos.yzj. All rights reserved.
//

#import "ViewController.h"
#import "YZJPhotoList.h"
#import "YZJSelectPhotoModel.h"
#import "PhotoView.h"

#define kTileWidth  80.f
#define kTileHeight kTileWidth
#define kTileMargin 7.f

@interface ViewController ()
{
    __weak IBOutlet UIButton *addImageBtn;
    __weak IBOutlet UIView *showImageView;
    
    NSString *prompt;
    
    // 拖动的tile的原始center坐标
    CGPoint _dragFromPoint;
    
    // 要把tile拖往的center坐标
    CGPoint _dragToPoint;
    
    // tile拖往的rect
    CGRect _dragToFrame;
    
    // 拖拽的tile是否被其他tile包含
    BOOL _isDragTileContainedInOtherTile;
    
}

@property (nonatomic, readonly) NSMutableArray *tileCoordinateArray;

@property (nonatomic, readonly) NSMutableArray *tileArray;

@property (nonatomic, strong) NSMutableArray<YZJSelectPhotoModel *> *selectPhotos;

@end

@implementation ViewController

@synthesize tileArray = _tileArray, tileCoordinateArray = _tileCoordinateArray, selectPhotos = _selectPhotos;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    addImageBtn.layer.borderWidth = 0.5f;
    addImageBtn.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
    
    showImageView.backgroundColor = UIColorFromRGB(0xe6e6e6);
    
    _selectPhotos = [@[] mutableCopy];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)addImageBtn_Click:(id)sender {
    
    YZJPhotoList *listVC = [[YZJPhotoList alloc] initWithStyle:UITableViewStylePlain];
    listVC.arraySelectPhotos = _selectPhotos;
    listVC.maxSelectCount = kMaxSelectCnt;
    
    WEAKSELF
    __weak typeof(listVC) weakPB = listVC;
    
    [listVC setDoneBlock:^(NSArray<YZJSelectPhotoModel *> *selPhotoModels) {
        __strong typeof(weakPB) strongPB = weakPB;
        [strongPB dismissViewControllerAnimated:YES completion:nil];
        _selectPhotos = [NSMutableArray arrayWithArray:selPhotoModels];
        
        //每次回调清除UI和数据  （已选功能，有bug暂时搁置）
        for (UIView *view in showImageView.subviews) {
            if ([view isKindOfClass:[PhotoView class]]) {
                [view removeFromSuperview];
            }
        }

        [self.tileArray removeAllObjects];
        [self.tileCoordinateArray removeAllObjects];
        
        //保存数据
        for(YZJSelectPhotoModel* model in selPhotoModels) {
            
            PhotoView *view = (PhotoView *) [[[UINib nibWithNibName:@"PhotoView" bundle:nil]
                                           instantiateWithOwner:self options:nil] objectAtIndex:0];
            [view initWithTarget:weakSelf panAction:@selector(dragTile:) delAction:@selector(delImageBtnPressed:) model:model];
            
            view.frame = [self createFrameLayoutTile];
            
            // 动态增长contectSize
            [showImageView addSubview:view];
            [weakSelf.tileArray addObject:view];
            
            //顺序保存位置
            [weakSelf.tileCoordinateArray addObject:[NSValue valueWithCGRect:view.frame]];
            
        }
    }];
    
    [listVC setCancelBlock:^{
        
    }];
    
    [self presentVC:listVC];

}

#pragma mark - presentVC
- (void)presentVC:(UIViewController *)vc
{
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = YES;
    
    [nav.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName: UIColorFromRGB(0x4d4d4d)}];
    [nav.navigationBar setBackgroundImage:[self imageWithColor:UIColorFromRGB(0xffffff)] forBarMetrics:UIBarMetricsDefault];
    [nav.navigationBar setTintColor:[UIColor blackColor]];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
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

#pragma mark - delect action
- (void)delImageBtnPressed:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    PhotoView *tileView = (PhotoView *)[btn superview];
    
    [_selectPhotos removeObject:tileView.model];
    
    [tileView setHidden:YES];
    [_tileArray removeObject:tileView];
    
    [self reorgnizeExceptView:nil];
    [_tileCoordinateArray removeLastObject];
    
}

#pragma mark - 手势操作

- (BOOL)dragTile:(UIPanGestureRecognizer *)recognizer
{
    switch ([recognizer state])
    {
        case UIGestureRecognizerStateBegan:
            [self dragTileBegan:recognizer];
            break;
        case UIGestureRecognizerStateChanged:
            [self dragTileMoved:recognizer];
            break;
        case UIGestureRecognizerStateEnded:
            [self dragTileEnded:recognizer];
            break;
        default: break;
    }
    return YES;
}

- (void)dragTileBegan:(UIPanGestureRecognizer *)recognizer
{
    _dragFromPoint = recognizer.view.center;
    [UIView animateWithDuration:0.2f animations:^{
        recognizer.view.transform = CGAffineTransformMakeScale(1.05, 1.05);
        recognizer.view.alpha = 0.8;
    }];
}

- (void)dragTileMoved:(UIPanGestureRecognizer *)recognizer
{
    CGPoint translation = [recognizer translationInView:showImageView];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer.view.superview bringSubviewToFront:recognizer.view];
    [recognizer setTranslation:CGPointZero inView:showImageView];
    
    [self pushedTileMoveToDragFromPointIfNecessaryWithTileView:(PhotoView *)recognizer.view];
}


//判别步骤
//1，判定其原来的位置；
//2，判定其要去的位置；
//3，重新排列位置
- (void)pushedTileMoveToDragFromPointIfNecessaryWithTileView:(PhotoView *)tileView
{
    //检查是否需要重新挪动位置
    NSUInteger detectedIndex = -1;
    
    for (NSValue *item in self.tileCoordinateArray) {
        CGRect frame = [item CGRectValue];
        
        if (CGRectContainsPoint(frame, tileView.center)) {
            detectedIndex = [self.tileCoordinateArray indexOfObject:item];
            
            if (detectedIndex == [self.tileArray indexOfObject:tileView]) {
                return;
            }
            else
            {
                break;
            }
        }
    }
    
    if (detectedIndex == -1) {
        return;
    }
    
    [self.tileArray removeObject:tileView];
    [self.tileArray insertObject:tileView atIndex:detectedIndex];
    
    [self reorgnizeExceptView:tileView];
}

- (void)dragTileEnded:(UIPanGestureRecognizer *)recognizer
{
    [UIView animateWithDuration:0.2f animations:^{
        recognizer.view.transform = CGAffineTransformMakeScale(1.f, 1.f);
        recognizer.view.alpha = 1.f;
    }];
    
    [UIView animateWithDuration:0.2f animations:^{
        if (_isDragTileContainedInOtherTile)
            recognizer.view.center = _dragToPoint;
        else
            recognizer.view.center = _dragFromPoint;
    }];
    
    _isDragTileContainedInOtherTile = NO;
}


-(void)reorgnizeExceptView:(PhotoView *)tileView
{
    for (PhotoView *item in self.tileArray)
    {
        NSUInteger index = [self.tileArray indexOfObject:item];
        CGRect     frame = [[self.tileCoordinateArray objectAtIndex:index] CGRectValue];
        
        if (item == tileView)
        {
            _dragToPoint = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            _dragToFrame = frame;
            _isDragTileContainedInOtherTile = YES;
        }
        else
        {
            [UIView animateWithDuration:0.2 animations:^{
                item.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
            }];
        }
    }
    
}


#pragma mark - Frame
- (CGRect)createFrameLayoutTile
{
    int counter = (int)self.tileArray.count;
    
    int marginTop   = (kTileHeight + kTileMargin) * (counter / 3 + 1) - 80;
    int marginLeft  = 14 + (kTileHeight + kTileMargin) * (counter % 3);
    
    return CGRectMake(marginLeft, marginTop, kTileWidth, kTileHeight);
}


#pragma mark - lazy loading
- (NSMutableArray *)tileArray
{
    if (!_tileArray)
    {
        _tileArray = [[NSMutableArray alloc] init];
    }
    return _tileArray;
}

- (NSMutableArray *)tileCoordinateArray
{
    if (!_tileCoordinateArray)
    {
        _tileCoordinateArray = [[NSMutableArray alloc] init];
    }
    return _tileCoordinateArray;
}


@end
