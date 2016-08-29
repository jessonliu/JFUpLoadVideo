//
//  JFCompressionVideo.h
//  textUpLoad
//
//  Created by iOS-Developer on 16/2/19.
//  Copyright © 2016年 iOS-Jessonliu. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVFoundation/AVFoundation.h>

/**
 *  压缩成功Block
 *
 *  @param resultPath 返回压缩成功的视频路径
 */
typedef void (^CompressionSuccessBlock)(NSString *resultPath,float memorySize); // 定义成功的Block 函数

@interface JFCompressionVideo : NSObject

/**
*  method Comperssion Video  压缩视频的方法, 该方法将压缩过的视频保存到沙河文件, 如果压缩过的视频不需要再进行保留, 可调用 removeCompressedVideoFromDocuments 方法, 将其删除即可
*
*  @param url             SourceVideoURL  被压缩视频的URL
*  @param compressionType 压缩可选类型
 
        AVAssetExportPresetLowQuality
        AVAssetExportPresetMediumQuality
        AVAssetExportPresetHighestQuality
        AVAssetExportPreset640x480
        AVAssetExportPreset960x540
        AVAssetExportPreset1280x720
        AVAssetExportPreset1920x1080
        AVAssetExportPreset3840x2160
 
*
*  @return 返回压缩后的视频路径
*/
+ (void)compressedVideoOtherMethodWithURL:(NSURL *)url compressionType:(NSString *)compressionType compressionResultPath:(CompressionSuccessBlock)resultPathBlock;

/**
 *  获取视频的大小
 *
 *  @return 返回视频的大小 float 类型
 */
+ (float)countVideoTotalMemorySizeWithURL:(NSURL *)url;

/**
 *  清楚沙盒文件中, 压缩后的视频所有
 */
+ (void)removeCompressedVideoFromDocuments;


@end
