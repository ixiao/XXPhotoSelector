//
//  XXPhotosViewController.m
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/14.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import "XXPhotosViewController.h"
#import "XXPhotoSelector.h"
#import "XXCollectionViewCell.h"
#import "XXAssetModel.h"
#import "XXImageManager.h"

@interface XXPhotosViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITableViewDelegate,UITableViewDataSource>{
    
    UIButton * previewBtn;
    UIButton * originalBtn;
    UIButton * nextBtn;
    UIButton * cancelBtn;
    UIButton * albumBtn;
    
}
@property (nonatomic, strong) XXCollectionView * collectionView;
@property (nonatomic, strong) UIView * bottomView;
@property (nonatomic, strong) UIImagePickerController * imagePickerController;
@property (nonatomic, strong) XXNavgationController * navController;
@property (nonatomic, strong) NSMutableArray * photosArray;

@property (nonatomic, strong) UIImageView * previewImage;
@property (nonatomic, strong) UITableView * photoAlbumTable;
@property (nonatomic, strong) UIView      * maskView;

@end

static NSString * const XXCollectionCellID = @"XXCollectionCellID";
static NSString * const XXPhotoAlbumCellID = @"XXPhotoAlbumCellID";

@implementation XXPhotosViewController


- (void)initializeConfiguration
{
    _columnNumber = 3;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeConfiguration];
    
    [[XXImageManager manager]getCameraRollAlbum:YES allowPickingImage:YES completion:^(XXAlbumModel *model) {
        _albumModel = model;
        NSLog(@"=-=-=%@",model.name);
        _photosArray = [NSMutableArray arrayWithArray:model.modelsArr];
        [self initUI];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark UICollection Delegate & DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return _photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WS(ws);
    XXCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:XXCollectionCellID forIndexPath:indexPath];
    XXAssetModel  * model = _photosArray[indexPath.row];
    cell.asset = model;
    
    cell.didSelectPhotoBlock = ^(BOOL isSelect){
        
        if (isSelect) {//选中
            model.isSelector = YES;
            [ws.selectedModels addObject:model];
            [ws refreshBottomToolBarStatus];
        }else
        {
            model.isSelector = NO;
            [ws.selectedModels removeObject:model];
            [ws refreshBottomToolBarStatus];
        }
    };
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    WS(ws);
    XXAssetModel  * model = _photosArray[indexPath.row];
    [[XXImageManager manager]getOriginalPhotoWithAsset:model.asset completion:^(UIImage *photo, NSDictionary *info) {
        ws.previewImage.image = photo;
        [[UIApplication sharedApplication].windows.lastObject addSubview:ws.previewImage];
    }];
}
#pragma mark UITableView DataSource & Delegate

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albumArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXPhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:XXPhotoAlbumCellID];
    if (!cell) {
        cell = [[XXPhotoAlbumCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:XXPhotoAlbumCellID];
    }
    cell.album = self.albumArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    XXAlbumModel * album = self.albumArray[indexPath.row];
    [albumBtn setTitle:album.name forState:UIControlStateNormal];
    self.photosArray = album.modelsArr.mutableCopy;
    [self.collectionView reloadData];
    [self refactorCodeForClickAlbumButton];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

#pragma mark 刷新Bottom 和 nav
- (void)refreshBottomToolBarStatus {
    
    if (_selectedModels.count > 0){
        [nextBtn setTitle:[NSString stringWithFormat:@"Next(%zd)",_selectedModels.count] forState:UIControlStateNormal];
        nextBtn.selected = YES;
        previewBtn.selected = YES;
        nextBtn.backgroundColor = K_COLOR_MASTER;
        
    }else{
        previewBtn.selected = NO;
        nextBtn.selected = NO;
        [nextBtn setTitle:[NSString stringWithFormat:@"Next"] forState:UIControlStateNormal];
        nextBtn.backgroundColor = [UIColor whiteColor];
    }
    
}
#pragma mark Init UI
- (void)initUI
{
    [self checkSelectedModels];
    [self initCollectionView];
    [self initBottomTooBar];
}

- (void)checkSelectedModels {
   [[XXImageManager manager]getAllAlbums:YES allowPickingImage:YES completion:^(NSArray<XXAlbumModel *> *models) {
       _albumArray = [NSMutableArray arrayWithArray:models];
       [self.photoAlbumTable reloadData];
   }];
}
- (void)initCollectionView
{
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.photoAlbumTable];
    
    [self.collectionView registerClass:[XXCollectionViewCell class] forCellWithReuseIdentifier:XXCollectionCellID];
    [self.photoAlbumTable registerClass:[XXPhotoAlbumCell class] forCellReuseIdentifier:XXPhotoAlbumCellID];
}
- (void)initBottomTooBar
{
    nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    nextBtn.frame = CGRectMake(SCREEN_WIDTH - 80, 0, 80, 30);
    nextBtn.backgroundColor = [UIColor whiteColor];
    [nextBtn setTitle:@"Next" forState:UIControlStateNormal];
    [nextBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
    [nextBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [nextBtn addTarget:self action:@selector(rightBarButtonNext:) forControlEvents:UIControlEventTouchUpInside];
    nextBtn.layer.borderWidth = 1;
    nextBtn.layer.borderColor = [UIColor lightGrayColor].CGColor;
    nextBtn.layer.cornerRadius = 3;
    nextBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    nextBtn.clipsToBounds = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:nextBtn];
    
    cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    cancelBtn.frame = CGRectMake(0, 0, 60, 30);
    [cancelBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(leftBarButtonCancel:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancelBtn setTitle:@"Cancel" forState:UIControlStateNormal];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:cancelBtn];
    
    [self.view addSubview:self.bottomView];
    
    albumBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumBtn.titleLabel sizeToFit];
    [albumBtn setTitle:@"相机胶卷" forState:UIControlStateNormal];
    [albumBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [albumBtn addTarget:self action:@selector(photoAlbumSelected:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.titleView = albumBtn;
}

#pragma mark Lazy load
- (XXCollectionView *)collectionView
{
    if (!_collectionView) {
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc]init];
        CGFloat margin = 5;
        CGFloat itemW = (SCREEN_WIDTH - (_columnNumber + 1) * margin) / _columnNumber;
        flowLayout.itemSize = CGSizeMake(itemW, itemW);
        flowLayout.minimumLineSpacing = margin;
        flowLayout.minimumInteritemSpacing = margin;
        
        CGFloat top = 0;
        CGFloat collectionH = SCREEN_HEIGHT - 40 - top;
        _collectionView = [[XXCollectionView alloc]initWithFrame:CGRectMake(0, top, SCREEN_WIDTH, collectionH) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.contentInset = UIEdgeInsetsMake(margin, margin, margin, margin);
        _collectionView.alwaysBounceHorizontal = NO;
        _collectionView.contentSize = CGSizeMake(SCREEN_WIDTH, ((self.albumModel.albumCount + self.columnNumber) / self.columnNumber ) * SCREEN_HEIGHT);
        _collectionView.backgroundColor = [UIColor whiteColor];
    }
    return _collectionView;
}
- (UIImagePickerController *)imagePickerController
{
    if (!_imagePickerController) {
        _imagePickerController = [[UIImagePickerController alloc]init];
        _imagePickerController.delegate = self;
        _imagePickerController.navigationBar.barTintColor = self.navigationController.navigationBar.barTintColor;
        _imagePickerController.navigationBar.tintColor = self.navigationController.navigationBar.tintColor;
    }
    return _imagePickerController;
}

- (UIView *)bottomView
{
    if (!_bottomView) {
        
        CGFloat pading = 15,topMargin = 5,btnW = 60;
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-40, SCREEN_WIDTH, 40)];
        _bottomView.backgroundColor = [UIColor whiteColor];
        
        previewBtn = [self buttonForBottomBarImage:@"Preview"];
        previewBtn.frame = CGRectMake(pading, topMargin, btnW, 30);
        [previewBtn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        
        originalBtn = [self buttonForBottomBarImage:@"Original"];
        originalBtn.frame = CGRectMake(previewBtn.maxX + pading, topMargin, btnW, 30);
        
        [_bottomView addSubview:previewBtn];
        [_bottomView addSubview:originalBtn];
    }
    return _bottomView;
}
- (NSMutableArray<XXAssetModel *> *)selectedModels
{
    if (!_selectedModels) {
        _selectedModels = [NSMutableArray array];
    }
    return _selectedModels;
}
- (UITableView *)photoAlbumTable
{
    if (!_photoAlbumTable) {
        _photoAlbumTable = [[UITableView alloc]initWithFrame:CGRectMake(0, -SCREEN_HEIGHT*0.66 + 64, SCREEN_WIDTH, SCREEN_HEIGHT*0.66)];
        _photoAlbumTable.delegate = self;
        _photoAlbumTable.dataSource = self;
        _photoAlbumTable.tableFooterView = [UIView new];
    }
    return _photoAlbumTable;
}
- (UIView *)maskView
{
    if (!_maskView) {
        _maskView = [[UIView alloc]initWithFrame:SCREEN_RECT];
        UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 100)];
        view.backgroundColor = [UIColor colorWithRed:0.84 green:0.84 blue:0.84 alpha:1];
        [_maskView addSubview:view];
        
        _maskView.backgroundColor = [UIColor colorWithRed:0.44 green:0.44 blue:0.44 alpha:0.6];
        _maskView.hidden = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMaskViewAction)];
        [_maskView addGestureRecognizer:tap];
    }
    return _maskView;
}

-(UIImageView *)previewImage
{
    if (!_previewImage) {
        _previewImage = [[UIImageView alloc]initWithFrame:SCREEN_RECT];
        _previewImage.backgroundColor = [UIColor blackColor];
        _previewImage.contentMode = UIViewContentModeScaleAspectFit;
        _previewImage.userInteractionEnabled = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapPreViewImage:)];
        [_previewImage addGestureRecognizer:tap];
    }
    return _previewImage;
}

#pragma mark Customer Private Action
- (void)photoAlbumSelected:(UIButton *)sender
{
    [self refactorCodeForClickAlbumButton];
}
- (void)clickMaskViewAction
{
    [self refactorCodeForClickAlbumButton];
}
- (void)leftBarButtonCancel:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)rightBarButtonNext:(UIBarButtonItem *)sender
{
    NSLog(@"select:%@",self.selectedModels);
}
- (void)tapPreViewImage:(UIGestureRecognizer *)recognize
{
    [self.previewImage removeFromSuperview];
}
- (UIButton *)buttonForBottomBarImage:(NSString *)imageStr
{
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:imageStr forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:14];
    [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    button.layer.borderColor = K_Color(224, 224, 224).CGColor;
    button.layer.borderWidth = 1;
    button.layer.cornerRadius = 2;
    button.layer.masksToBounds = YES;
    return button;
}
- (void)refactorCodeForClickAlbumButton
{
    albumBtn.selected = !albumBtn.selected;
    albumBtn.enabled = NO;
    albumBtn.selected ? [self.photoAlbumTable showPositionAnimationShowing:YES]:[self.photoAlbumTable showPositionAnimationShowing:NO];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.maskView.hidden = !albumBtn.selected;
        albumBtn.enabled = YES;
    });
}
@end

#pragma mark XXNavgationController
@implementation XXNavgationController

@end
#pragma mark XXCollectionView
@implementation XXCollectionView

@end
