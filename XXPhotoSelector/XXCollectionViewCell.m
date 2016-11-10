//
//  XXCollectionViewCell.m
//  XXPhotoSelector
//
//  Created by IOS Developer on 16/10/17.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import "XXCollectionViewCell.h"
#import "XXAssetModel.h"
#import "XXImageManager.h"

@interface XXCollectionViewCell ()
@property (strong, nonatomic) UIImageView *imageView;

@end

static CGFloat SelectBtnW = 30;
static CGFloat Margin     = 5;
@implementation XXCollectionViewCell
-(instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.imageView];
       [self.contentView addSubview:self.selectBtn];
    }
    return self;
}
-(void)setAsset:(XXAssetModel *)asset
{
    WS(ws);
    self.assetIdentifier = asset.asset.localIdentifier;
    PHImageRequestID requestID = [[XXImageManager manager] getPhotoWithAsset:asset.asset width:self.w completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
        ws.imageView.image = photo;
    }];
    self.imageRequestID = requestID;
    self.selectBtn.selected = asset.isSelector;
}

#pragma mark Lazy load

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.w, self.h)];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.clipsToBounds = YES;
    }
    return _imageView;
}

- (UIButton *)selectBtn
{
    if (!_selectBtn) {
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.frame = CGRectMake(self.w-SelectBtnW - Margin, Margin, SelectBtnW, SelectBtnW);
        [_selectBtn setImage:[UIImage imageNamed:@"compose_photo_preview_default"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"compose_photo_preview_right"] forState:UIControlStateSelected];
        [_selectBtn addTarget:self action:@selector(selectPhotoAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectBtn;
}

- (void)selectPhotoAction:(UIButton *)sender
{
    sender.selected =! sender.selected;
    
    if (self.didSelectPhotoBlock) {
        self.didSelectPhotoBlock(sender.selected);
    }
    
}

@end

@implementation XXPhotoAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
    }
    return self;
}
- (void)setAlbum:(XXAlbumModel *)album
{
    self.textLabel.text = album.name;
}



@end

@implementation UIView (XX)

- (CGSize  )size
{
    return  self.frame.size;
}
- (CGPoint )origin
{
    return self.frame.origin;
}
- (CGFloat )x
{
    return self.origin.x;
}
- (CGFloat )y
{
    return self.origin.y;
}
- (CGFloat )w
{
    return self.size.width;
}
- (CGFloat )h
{
    return self.size.height;
}
- (CGFloat )centerX
{
    return self.center.x;
}
- (CGFloat )centerY
{
    return self.center.y;
}
- (CGFloat )maxY
{
    return CGRectGetMaxY(self.frame);
}
- (CGFloat )maxX
{
    return CGRectGetMaxX(self.frame);
}
- (void)showPositionAnimationShowing:(BOOL )isShowing
{
    CGFloat  positionValue = SCREEN_HEIGHT * 0.68;
    CGFloat  endValue      = SCREEN_HEIGHT * 0.02;
    NSTimeInterval starTime = 0.3;
    NSTimeInterval endTime  = 0.2;
    
    if (isShowing) {
        [UIView animateWithDuration:starTime animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, positionValue);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:endTime animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height);
            }];
        }];
    }else
    {
        [UIView animateWithDuration:endTime animations:^{
            self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height + endValue);
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:starTime animations:^{
                self.transform = CGAffineTransformMakeTranslation(0, self.bounds.size.height- positionValue);
            }];
        }];
    }
}


@end
