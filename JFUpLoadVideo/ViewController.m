//
//  ViewController.m
//  JFUpLoadVideo
//
//  Created by iOS-Developer on 16/7/1.
//  Copyright © 2016年 Jessonliu. All rights reserved.
//

#import "ViewController.h"
#import "ZYQAssetPickerController.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "UpLoadImage.h"
#import "JFCompressionVideo.h"
#import "NetWorkManeger.h"


//视频存储路径
#define KVideoUrlPath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]

#define PostVideoURL @"上传视频连接"

@interface ViewController () <ZYQAssetPickerControllerDelegate, UINavigationControllerDelegate, UpLoadImageDeletate>
@property (weak, nonatomic) IBOutlet UIImageView *videoImag;
@property (nonatomic, retain) ALAssetRepresentation *representation;
@property (nonatomic, retain) NSString *imagePath;  // 上传图片成功返回的数据


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
}


// 打开本地视频库
- (IBAction)chooseVideoButtonAction:(id)sender {
    [self upLoadVideo];
}

- (void)upLoadVideo {
    // 打开图库所有视频
    ZYQAssetPickerController *picker = [[ZYQAssetPickerController alloc] init];
    picker.maximumNumberOfSelection = 0;
    picker.assetsFilter = [ALAssetsFilter allVideos];
    picker.showEmptyGroups=NO;
    picker.delegate=self;
    
    picker.selectionFilter = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        if ([[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyType] isEqual:ALAssetTypeVideo]) {
            NSTimeInterval duration = [[(ALAsset*)evaluatedObject valueForProperty:ALAssetPropertyDuration] doubleValue];
            return duration >= 5;
        } else {
            return YES;
        }
    }];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - ZYQAssetPickerController Delegate
-(void)assetPickerController:(ZYQAssetPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    ALAsset *asset=assets[0];
    _representation = asset.defaultRepresentation;
    
    
    UIImage *tempImg = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    
    self.videoImag.image = tempImg;
    NSString *typeStr = @"视频";
    NSData *data = UIImageJPEGRepresentation(tempImg, 1);
    [self videoWithUrl:_representation.url withFileName:_representation.filename];
    
    NSString* picPath = [NSString stringWithFormat:@"%@/%@",KVideoUrlPath,_representation.filename];
    NSMutableDictionary *objDict = [[NSMutableDictionary alloc] init];
    if(data){
        [objDict setObject:data forKey:@"header"];
    }
    [objDict setObject:picPath  forKey:@"path"];
    [objDict setObject:typeStr forKey:@"type"];
    [objDict setObject:_representation.filename  forKey:@"name"];
    
}

// 将原始视频的URL转化为NSData数据,写入沙盒
- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName
{
    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
    // 创建存放原始图的文件夹--->VideoURL
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:KVideoUrlPath]) {
        [fileManager createDirectoryAtPath:KVideoUrlPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    
    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if (url) {
            
            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
                ALAssetRepresentation *rep = [asset defaultRepresentation];
                NSString * videoPath = [KVideoUrlPath stringByAppendingPathComponent:fileName];
                
                const char *cvideoPath = [videoPath UTF8String];
                FILE *file = fopen(cvideoPath, "a+");
                if (file) {
                    const int bufferSize = 11024 * 1024;
                    // 初始化一个1M的buffer
                    Byte *buffer = (Byte*)malloc(bufferSize);
                    NSUInteger read = 0, offset = 0, written = 0;
                    NSError* err = nil;
                    if (rep.size != 0)
                    {
                        do {
                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
                            written = fwrite(buffer, sizeof(char), read, file);
                            offset += read;
                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
                    }
                    // 释放缓冲区，关闭文件
                    free(buffer);
                    buffer = NULL;
                    fclose(file);
                    file = NULL;
                    
                    // UI的更新记得放在主线程,要不然等子线程排队过来都不知道什么年代了,会很慢的
                    dispatch_async(dispatch_get_main_queue(), ^{
                        //                        [_tableView reloadData];
                    });
                }
            } failureBlock:nil];
        }
    });
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)submitVideoAction:(id)sender {
    
           // 获取 视频Data流
        Byte *buffer = (Byte*)malloc((unsigned long)_representation.size);
        NSUInteger buffered = [_representation getBytes:buffer fromOffset:0.0 length:((unsigned long)_representation.size) error:nil];
        NSData *tempData = [NSData dataWithBytesNoCopy:buffer length:buffered freeWhenDone:YES];
        
        __weak typeof(self)weakSelf = self;
        
        // 获取视频大小
        NSInteger videoMemerySize = tempData.length / (1024 * 1024);
        
        // 如果视频大于40M 则不允许上传
        if (videoMemerySize > 200) {
            
            // 提示 @"视频大于200M, 无法上传"
        } else {
            // 提示 @"正在上传, 请耐心等候..."];
            // 开辟线程, 进行数据处理
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
                // 图片上传工具
                UpLoadImage *upLoadMeneger = [UpLoadImage new];
                upLoadMeneger.delegate = weakSelf;  // 设置代理, 回调视频上传的结果
                
                // 发送图片上传的请求
                [upLoadMeneger postImageWithURLString:@"上传图片的连接"  parameter:@{@"传图的参数":@""} image:weakSelf.videoImag.image success:^(UpLoadImage *net, id object) {
                    
                    if ([object[@"result"] integerValue] == 1) {
                        // JFLog(@"缩略图上传成功");
                        // 缩略图上传成功, 取出缩略图的路径
                        NSArray *tempArr = object[@"data"];
                        weakSelf.imagePath = tempArr[0][@"p"];
                        if (videoMemerySize <= 8) {
                            // 视频小于8M  直接上传
                            // 上传视频
                            [upLoadMeneger uploadFileWithMediaData:tempData url:PostVideoURL params:@{@"上传视频参数":@""}];
                        } else {
                            // 如果视频大于 8M 则压缩上传,
                            [weakSelf compressionVideoWithURL:weakSelf.representation.url videoMemorySize:videoMemerySize upLoadMeneger:upLoadMeneger];
                        }
                    } else {
                    }
                } fialBlock:^(UpLoadImage *net, NSError *error) {
                    
                }];
            });
        }
//        JFLog(@"提交数据");
    }


// 视频压缩, 根据原视频的大小不同, 进行不同强度的压缩
- (void)compressionVideoWithURL:(NSURL *)url videoMemorySize:(NSInteger)videoMemerySize upLoadMeneger:(UpLoadImage *)upLoadMeneger {
    
    
    // 设置参数
    __block NSDictionary *paraDic = @{@"mid":@"",
                                      @"token":@""};
    __block NSData *upData;
    __weak typeof(self)weakSelf = self;
    // 调用压缩类, 进行压缩
    [JFCompressionVideo compressedVideoOtherMethodWithURL:url compressionType:AVAssetExportPresetMediumQuality compressionResultPath:^(NSString *resultPath, float memorySize) {
        
        // 测试视频压缩, 大文件压缩上传
        upData = [NSData dataWithContentsOfFile:resultPath];
        
        NSInteger fileSize = upData.length / (1024 * 1024);
        if (fileSize >= 9 ) {
            // 如果压缩后晚间大于 9M 则不允许上传, 然后清理压缩文件
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                dispatch_async ( dispatch_get_main_queue (), ^{
//                    [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
//                    [weakSelf showHint:@"该视频过大无法上传"];
                    [weakSelf cleanAllVideoData];
                });
            });
        } else {
            // 上传视频
            [upLoadMeneger uploadFileWithMediaData:upData url:PostVideoURL params:paraDic];
        }
    }];
}


// 上传视频回调数据
- (void)upVideoBackDataWithDictionary:(NSDictionary *)dic {
    
    // 视频上传成功
    if ([dic[@"result"] integerValue] == 1) {
        // 保存视频连接
        NSArray *tempArr = dic[@"data"];
        NSString *videoPath = tempArr[0][@"p"];
        
        // 设置参数
        NSString *mid =  @"";// [UserInfoSingleTon defaultSingleTon].mid;
        NSString *token = @""; //[UserInfoSingleTon defaultSingleTon].token;
        
        NSDictionary *paraDic = @{
                                  @"mid":mid,
                                  @"token":token,
                                  @"video_img":self.imagePath,
                                  @"video":videoPath
                                  };
        
        __weak typeof(self)weakSelf = self;
        // 上传所有数据
        [NetWorkManeger postDataWithURL:@"shangch" parameter:paraDic successBlock:^(NetWorkManeger *net, id object) {
            if ([object[@"result"] integerValue] == 1) {
                
                // 发送通知, 主界面刷新界面
                [[NSNotificationCenter defaultCenter] postNotificationName:@"isLogin" object:weakSelf userInfo:nil];
                // 清楚所有缓存
                [weakSelf cleanAllVideoData];
                
//                [weakSelf showHint:@"视频上传成功"];
                
                // 返回首界面
                [weakSelf.navigationController popViewControllerAnimated:YES];
            } else {
//                [weakSelf showHint:@"上传失败"];
            }
//            [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
            
        } fialBlock:^(NetWorkManeger *net, NSError *error) {
//            JFLog(@"%@", error);
        }];
    } else {
//        JFLog(@"发布失败");
    }
}

// 将字典转化为Json 数据
- (NSString *)getJsonDataWithDictionary:(NSDictionary *)dic {
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonStr;
}


//清空所有缓存
-(void)cleanAllVideoData {
    // 清楚相册选择视频时, 写入cath 文件的视频
    [[NSFileManager defaultManager] removeItemAtPath:KVideoUrlPath error:nil];
    // 清楚压缩视频时, 写入Documents 的视频文件
    [JFCompressionVideo removeCompressedVideoFromDocuments];
}


@end
