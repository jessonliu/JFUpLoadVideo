//
//  UpLoadImage.h
//  JOINUSART
//
//  Created by iOS-Developer on 16/1/4.
//  Copyright © 2016年 ios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class UpLoadImage;
typedef void (^SuccessBlock)(UpLoadImage *net, id object); // 定义成功的Block 函数
typedef void (^FialBlock)(UpLoadImage *net, NSError *error); // 定义失败的Block 函数



@protocol UpLoadImageDeletate <NSObject>

- (void)upVideoBackDataWithDictionary:(NSDictionary *)dic;

@end

@interface UpLoadImage : NSObject

@property (nonatomic, copy) SuccessBlock success;
@property (nonatomic, copy) FialBlock fial;
@property (nonatomic, assign) id <UpLoadImageDeletate> delegate;


/**
 *  上传图片
 *
 *  @param urlStr  postUrl
 *  @param para    参数Dic
 *  @param image   要上传的图片
 *  @param success 成功回调
 *  @param fial    失败回调
 */
- (void)postImageWithURLString:(NSString *)urlStr parameter:(NSDictionary *)para image:(UIImage *)image success:(SuccessBlock)success fialBlock:(FialBlock)fial;


/**
 *  上传视频
 *
 *  @param data   视频data
 *  @param url    上传连接
 *  @param params 参数
 */
- (void)uploadFileWithMediaData:(NSData *)data url:(NSString *)url params:(id)params;

@end
