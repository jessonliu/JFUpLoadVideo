//
//  NetWorkManeger.h
//  36.UIGiftSay
//
//  Created by laouhn on 15/9/23.
//  Copyright (c) 2015年 JHH. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NetWorkManeger;

// 创建代理

@protocol NetWorkManegerDelegate <NSObject>

@optional // 设置代理方法
- (void)getDataSuccess:(NetWorkManeger *)netWork object:(id)obg;
- (void)getDataFail:(NetWorkManeger *)netWork error:(NSError *)error;

@end
// Blcok 是匿名函数
// typedef 类型重命名
// 定义了一个有两个参数且参数值类型为(NetWorkManager,  id) 返回值为void类型的函数类型, 类型重命名为successBlock
typedef void (^successBlock)(NetWorkManeger *net, id object); // 定义成功时Block函数

typedef void (^fialBlock)(NetWorkManeger *net, NSError *error); // 定义失败时Block函数





@interface NetWorkManeger : NSObject





// 创建属性遵守协议
@property (nonatomic, assign) id<NetWorkManegerDelegate> deletate;

@property (nonatomic, copy) successBlock success;
@property (nonatomic, copy) fialBlock fial;



//- (void)getDataWithURL:(NSString *)urlStr parameter:(NSString *)para;

+ (void)postDataWithURL:(NSString *)urlStr parameter:(id)para successBlock:(successBlock)success fialBlock:(fialBlock)fial;


- (void)getDataWithURL:(NSString *)urlStr success:(successBlock)success fialBlock:(fialBlock)fial;








@end
