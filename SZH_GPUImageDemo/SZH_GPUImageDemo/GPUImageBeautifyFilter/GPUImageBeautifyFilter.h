//
//  GPUImageBeautifyFilter.h
//  SZH_GPUImageDemo
//
//  Created by 智衡宋 on 2017/9/16.
//  Copyright © 2017年 智衡宋. All rights reserved.
//

#import <GPUImage/GPUImage.h>
@class GPUImageCombinationFilter;
@interface GPUImageBeautifyFilter : GPUImageFilterGroup{
    GPUImageBilateralFilter            *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter   *cannyEdgeFilter;
    GPUImageCombinationFilter          *combinationFilter;
    GPUImageHSBFilter                  *hsbFilter;
}

@end
