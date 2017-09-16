//
//  ViewController.m
//  SZH_GPUImageDemo
//
//  Created by 智衡宋 on 2017/9/14.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#define ScreenWidth   [UIScreen mainScreen].bounds.size.width
#define ScreenHeight  [UIScreen mainScreen].bounds.size.height

#import "ViewController.h"
#import <GPUImage.h>
#import <Masonry.h>
#import "GPUImageBeautifyFilter.h"

@interface ViewController ()<GPUImageMovieDelegate,GPUImageMovieWriterDelegate>

@property(nonatomic,strong) GPUImageVideoCamera       *videocamera;//摄像
@property(nonatomic,strong) GPUImageView              *preview;//预览
@property(nonatomic,strong) GPUImageStillCamera       *stillCamera;//拍照
@property(nonatomic,strong) GPUImageMovie             *movie;
@property(nonatomic,strong) GPUImageFilterGroup       *filterGroup;//滤镜组
@property(nonatomic,strong) GPUImageBilateralFilter   *bilaterFilter;
@property(nonatomic,strong) GPUImageBrightnessFilter  *brightnessFilter;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    
    [self szh_beautifyGPUImage];
}


#pragma mark ----------------- GPUImage原生美颜

- (void)szh_protogenesisGPUImage {
    
    //创建视频源
    GPUImageVideoCamera *video = [[GPUImageVideoCamera alloc]initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    video.outputImageOrientation = UIInterfaceOrientationPortrait;
//    [video setCaptureSessionPreset:AVCaptureSessionPresetHigh];
    _videocamera = video;
    
    //创建最终预览
    GPUImageView *captureVideoPreview = [[GPUImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    [self.view insertSubview:captureVideoPreview atIndex:0];
    
    //创建滤镜组
    _filterGroup = [[GPUImageFilterGroup alloc]init];
    
    //磨皮滤镜
    GPUImageBilateralFilter *bilaterFilter = [[GPUImageBilateralFilter alloc]init];
    [_filterGroup addFilter:bilaterFilter];
    _bilaterFilter = bilaterFilter;
    //美白滤镜
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc]init];
    [_filterGroup addFilter:brightnessFilter];
    _brightnessFilter = brightnessFilter;
    
    //设置滤镜组链
    [bilaterFilter addTarget:brightnessFilter];
    [_filterGroup setInitialFilters:@[bilaterFilter]];
    _filterGroup.terminalFilter = brightnessFilter;
    
    //设置GPUImage响应链，从数据源 => 滤镜 => 最终界面效果
    [video addTarget:_filterGroup];
    [_filterGroup addTarget:captureVideoPreview];
    
    //必须调用startCameraCapture，底层才会把采集到的视频源，渲染到GPUImageView中，就能显示了。
    //开始采集视频
    [video startCameraCapture];
    
    [self szh_createTwoSliders];
    
}


- (void)szh_createTwoSliders {
    
    UISlider *oneSilder = [[UISlider alloc]init];
    [oneSilder addTarget:self action:@selector(oneSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:oneSilder];
    
    
    UISlider *twoSilder = [[UISlider alloc]init];
    [twoSilder addTarget:self action:@selector(twoSliderAction:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:twoSilder];
    
    
    [oneSilder mas_makeConstraints:^(MASConstraintMaker *make) {
        
        make.height.mas_equalTo(30);
        make.bottom.equalTo(twoSilder.mas_top).offset(-10);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
    
    [twoSilder mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.bottom.equalTo(self.view.mas_bottom).offset(-10);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
    }];
    
}

- (void)oneSliderAction:(UISlider *)slider {
    
    _brightnessFilter.brightness = slider.value;
    
}

- (void)twoSliderAction:(UISlider *)slider {
    
    // 值越小，磨皮效果越好
    CGFloat maxValue = 10;
    [_bilaterFilter setDistanceNormalizationFactor:(maxValue - slider.value)];
    
}


#pragma mark ----------------- GPUImage美颜滤镜

- (void)szh_beautifyGPUImage {
    UISwitch *switcher = [[UISwitch alloc] initWithFrame:CGRectMake(140, 80, 70, 30)];
    [switcher addTarget:self action:@selector(changeBeautyFilter:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:switcher];
    
    
    //  1.创建视频摄像头
    _videocamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPresetHigh cameraPosition:AVCaptureDevicePositionFront];
    //  2. 设置摄像头输出视频的方向
    _videocamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    //  开启捕获声音
    [_videocamera addAudioInputsAndOutputs];
    
    //镜像策略，这里这样设置是最自然的。跟系统相机默认一样。
    _videocamera.horizontallyMirrorRearFacingCamera = NO;
    _videocamera.horizontallyMirrorFrontFacingCamera = YES;
    
    
    //  3. 创建用于展示视频的GPUImageView
    GPUImageView *captureVideoPreview = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:captureVideoPreview atIndex:0];
    _preview = captureVideoPreview;
    
    //  4. 设置处理链
    [_videocamera addTarget:_preview];
    
    
    //  5.调用startCameraCapture采集视频,底层会把采集到的视频源，渲染到GPUImageView上，接着界面显示
    [_videocamera startCameraCapture];
    
}

- (void)changeBeautyFilter:(UISwitch *)sender
{
    if (sender.on) {
        
        // 移除之前所有的处理链
        [_videocamera removeAllTargets];
        
        // 创建美颜滤镜
        GPUImageBeautifyFilter *beautifyFilter = [[GPUImageBeautifyFilter alloc] init];
        // 设置GPUImage处理链，从数据->滤镜->界面展示
        [_videocamera addTarget:beautifyFilter];
        [beautifyFilter addTarget:_preview];
        
    } else {
        
        // 移除之前所有的处理链
        [_videocamera removeAllTargets];
        [_videocamera addTarget:_preview];
    }
}


#pragma mark -----------------  滤镜测试

- (void)szh_testGPUImage {
    
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
