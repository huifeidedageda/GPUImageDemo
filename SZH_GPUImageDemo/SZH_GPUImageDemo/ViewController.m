//
//  ViewController.m
//  SZH_GPUImageDemo
//
//  Created by 智衡宋 on 2017/9/14.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import "ViewController.h"
#import <GPUImage.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}


#pragma mark ----------------- 


#pragma mark -----------------  滤镜测试

- (void)testGPUImage {
    
    UIImage *image  = [UIImage imageNamed:@"x"];
    
    
    //GPUImage 滤镜
    GPUImageLanczosResamplingFilter *disFilter = [[GPUImageLanczosResamplingFilter alloc] init];
    
    [disFilter forceProcessingAtSize:self.view.frame.size];
    [disFilter useNextFrameForImageCapture];
    
    //获取数据源
    GPUImagePicture *stillImageSource  = [[GPUImagePicture alloc]initWithImage:image];
    
    //添加滤镜
    [stillImageSource addTarget:disFilter];
    //开始渲染
    [stillImageSource processImage];
    //获取渲染后的图片
    UIImage *newImage  = [disFilter imageFromCurrentFramebuffer];
    
    UIImageView *imageView = [[UIImageView alloc]initWithImage:newImage];
    imageView.frame = self.view.bounds;
    [self.view addSubview:imageView];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
