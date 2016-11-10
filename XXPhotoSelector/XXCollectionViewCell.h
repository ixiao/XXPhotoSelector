//
//  XXCollectionViewCell.h
//  XXPhotoSelector
//
//  Created by IOS Developer on 16/10/17.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class XXAssetModel;
@class XXAlbumModel;

@interface XXCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) XXAssetModel * asset;
@property (nonatomic, strong) UIButton * selectBtn;
@property (nonatomic, copy)   NSString * assetIdentifier;
@property (nonatomic, assign) PHImageRequestID imageRequestID;
@property (nonatomic, copy)  void (^didSelectPhotoBlock)(BOOL);
@end

@interface XXPhotoAlbumCell : UITableViewCell
@property (nonatomic, strong) UIImageView * albumIcon;
@property (nonatomic, strong) UILabel     * albumName;
@property (nonatomic, strong) UILabel     * albumCount;
@property (nonatomic, strong) XXAlbumModel* album;
@end

#define K_Color(r,g,b)  [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1]
#define K_COLOR_MASTER  K_Color(255,130,1)

#define WS(weakSelf)  __weak __typeof(&*self)weakSelf = self;

#ifdef DEBUG
#define XLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#define XLog(...)
#endif

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define SCREEN_RECT [UIScreen mainScreen].bounds
#define SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define SCREEN_MAX_LENGTH (MAX(SCREEN_WIDTH, SCREEN_HEIGHT))


@interface UIView (XX)

- (CGSize  )size;
- (CGPoint )origin;
- (CGFloat )x;
- (CGFloat )y;
- (CGFloat )w;
- (CGFloat )h;
- (CGFloat )centerX;
- (CGFloat )centerY;
- (CGFloat )maxY;
- (CGFloat )maxX;
- (void)showPositionAnimationShowing:(BOOL )isShowing;


@end

