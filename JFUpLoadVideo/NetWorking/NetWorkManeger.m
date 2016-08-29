//
//  NetWorkManeger.m
//  36.UIGiftSay
//
//  Created by laouhn on 15/9/23.
//  Copyright (c) 2015年 JHH. All rights reserved.
//

#import "NetWorkManeger.h"
#import "AFHTTPSessionManager.h"

@interface NetWorkManeger  () <NSURLConnectionDataDelegate, NSURLConnectionDelegate>

@property (nonatomic, strong) NSURLConnection *connection;

@property (nonatomic, strong) NSMutableData *data; // 用于存储data数据

@end

@implementation NetWorkManeger



+ (void)postDataWithURL:(NSString *)urlStr parameter:(id)para successBlock:(successBlock)success fialBlock:(fialBlock)fial {
    
    NetWorkManeger *net = [NetWorkManeger new];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"text/html"];
    
    [manager POST:urlStr parameters:para progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        // 请求成功
        success (net, responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        // 请求失败
        fial (net, error);
    }];
}






- (void)getDataWithURL:(NSString *)urlStr success:(successBlock)success fialBlock:(fialBlock)fial {
    // GET 请求
    // 创建URL 对象
    NSURL *url = [NSURL URLWithString:urlStr];
    // 创建求情 NSURLRequest
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // 链接
    [NSURLConnection sendAsynchronousRequest:request queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
        // 如果data存在, 解析, 成功回调
       id obj = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        success(self, obj);
            
        } else {
             // 反之, 失败回调;
            fial(self, nil);
        }

       
        
    }];
}


@end
