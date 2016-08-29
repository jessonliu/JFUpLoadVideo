//
//  UpLoadImage.m
//  JOINUSART
//
//  Created by iOS-Developer on 16/1/4.
//  Copyright © 2016年 ios. All rights reserved.
//

#import "UpLoadImage.h"
#import "AFHTTPSessionManager.h"
@interface UpLoadImage ()

@end

@implementation UpLoadImage

- (void)postImageWithURLString:(NSString *)urlStr parameter:(NSDictionary *)para image:(UIImage *)image success:(SuccessBlock)success fialBlock:(FialBlock)fial {
    
    __block UIImage *upImage = image;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        CGFloat dividend = 1024.0 * 1024.0;
        //得到图片的data
        NSData *data = [self imageConversationDataWith:upImage];
        
        //判断图片所占内存的大小
        CGFloat memory = data.length / dividend;
        // 循环压缩图片, 知道满足要求
        while (memory > 2.0) {
            upImage = [self scaleToSize:upImage scale:0.9];
            data = [self imageConversationDataWith:upImage];
            memory = data.length / dividend;
        }
        // AFNetWorking 上传图片
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
        [manager POST:urlStr parameters:para constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:data
                                        name:@"Pic"
                                    fileName:@"Jessonliu.png"
                                    mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            // 上传成功
            success (self, responseObject);
            if ([responseObject[@"result"] integerValue] == 1) {
//                JFLog(@"上传成功");
            } else {
//                JFLog(@"失败%@", responseObject[@"msg"]);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            // 上传失败
            fial (self, error);
        }];
    });
}

- (NSData *)imageConversationDataWith:(UIImage *)image {
    NSData *data;
    if (UIImagePNGRepresentation(image)) {
        // png图像。
        data = UIImagePNGRepresentation(image);
    }else {
        // JPEG图像。
        data = UIImageJPEGRepresentation(image, 1);
    }
    return data;
}

- (UIImage *)scaleToSize:(UIImage *)image scale:(CGFloat)scale{
    // 创建一个bitmap的context
    CGSize size = CGSizeMake(image.size.width * scale, image.size.height * scale);
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}




- (void)uploadFileWithMediaData:(NSData *)data url:(NSString *)url params:(id)params
{
    
//    __weak typeof(self)weakSelf = self;
    // AFNetWorking 上传视频
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",
                                                         @"text/plain",
                                                         @"application/json",nil];

    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    [manager POST:url parameters:params constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
        [formData appendPartWithFileData:data
                                    name:@"videoJF"
                                fileName:@"video1.mp4"
                                mimeType:@"video/quicktime"];
    } progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(upVideoBackDataWithDictionary:)]) {
            [self.delegate upVideoBackDataWithDictionary:responseObject];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 上传失败
      
    }];
}


@end
