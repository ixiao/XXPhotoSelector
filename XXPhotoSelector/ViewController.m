//
//  ViewController.m
//  XXPhotoSelector
//
//  Created by 闫潇 on 16/10/14.
//  Copyright © 2016年 闫潇. All rights reserved.
//

#import "ViewController.h"
#import "XXPhotoSelector.h"

@interface ViewController ()
{
    
}
//@property (nonatomic, strong) XXNavgationController * photo;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blueColor];
    
    self.navigationController.navigationBarHidden = YES;
    
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(100, 300, 100, 30);
    [btn setTitle:@"click" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(momowo:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
//       [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:VC animated:YES completion:nil];
    
}
- (void)momowo:(id)sender
{
    XXPhotosViewController * photo = [XXPhotosViewController new];
    XXNavgationController * nav = [[XXNavgationController alloc]initWithRootViewController:photo ];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
