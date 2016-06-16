//
//  ViewController.m
//  MutiPhotoUpload_ZLPhotoLib_Demo
//
//  Created by admin on 16/6/16.
//  Copyright © 2016年 AlezJi. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Ext.h"
#import "UIImageView+WebCache.h"

//发车照片  上传多张
#import "ZLCameraViewController.h"
#import "ZLPhotoPickerViewController.h"
#import "ZLPhoto.h"
#define kMaxUploads 3
#define kPhotoWidth  (kScreenWidth-40)/3
#define kPhotoHeight   (kScreenWidth-40)/3

#define kScreenWidth [UIScreen mainScreen].bounds.size.width
#define kScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<ZLPhotoPickerViewControllerDelegate>
@property (strong, nonatomic) UIView *displayPhotoView;//添加照片的展示视图
@property (strong, nonatomic) NSMutableArray *photoArr;//添加的照片数组
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

#pragma mark - 在确认上传的时候需要注意 数组个数比图片多1  因为图片有一张添加的按钮    所以取出来的时候需要-1
    

    self.photoArr =[NSMutableArray array];


    self.displayPhotoView = [[UIView alloc]initWithFrame:CGRectMake(0,100, kScreenWidth, kScreenWidth/3)];
    self.displayPhotoView.backgroundColor  = [UIColor whiteColor];
    [self.view addSubview:self.displayPhotoView];
    [self creatAddPhotoView];//添加照片
}



- (void)creatAddPhotoView {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(10, 10, kPhotoWidth, kPhotoHeight)];
    //    view.backgroundColor = Red_Color;
    [self.displayPhotoView addSubview:view];
    
    UIButton *addPhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addPhotoBtn.frame = CGRectMake(0, 0, view.width, view.height-20);
    [addPhotoBtn setBackgroundImage:[UIImage imageNamed:@"mn_addImg"] forState:UIControlStateNormal];
    [addPhotoBtn addTarget:self action:@selector(addThumbPhoto) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:addPhotoBtn];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, addPhotoBtn.y+addPhotoBtn.height, addPhotoBtn.width, 20)];
    label.text = @"添加照片";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor blackColor];
    [view addSubview:label];
    
    [self.photoArr addObject:view];
    
}
//上传照片
- (void)addThumbPhoto
{
    [self.view endEditing:YES];
    
    UIAlertController *alertDialog = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    //添加
    __weak typeof(self) weakSelf = self;
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        //拍照
        [weakSelf openZLCameraPickerVC];
    }];
    UIAlertAction *neverAction = [UIAlertAction actionWithTitle:@"从相册获取" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // 相册
        [weakSelf openZLPhotoPickerVC];
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        // 取消按键
    }];
    
    // 添加操作（顺序就是呈现的上下顺序）
    [alertDialog addAction:laterAction];
    [alertDialog addAction:neverAction];
    [alertDialog addAction:okAction];
    
    // 呈现警告视图
    [self presentViewController:alertDialog animated:YES completion:nil];

    
    
 
    
}


//照相
-(void)openZLCameraPickerVC
{
    ZLCameraViewController *cameraVc = [[ZLCameraViewController alloc] init];
    // 拍照最多个数
    NSInteger currentImgs = self.photoArr.count - 1;
    if (currentImgs >= kMaxUploads) {
        cameraVc.maxCount = 0;
    }else{
        cameraVc.maxCount = kMaxUploads - currentImgs;
    }
    __weak typeof(self) weakSelf = self;
    cameraVc.callback = ^(NSArray *cameras){
        [weakSelf reloadFBImageViewWithPhotoAssets:cameras];
    };
    [cameraVc showPickerVc:self];
    
}
#pragma mark - 打开ZLPhotoPickerViewController - 相册
//相册
-(void)openZLPhotoPickerVC
{
    ZLPhotoPickerViewController *pickerVc = [[ZLPhotoPickerViewController alloc] init];
    pickerVc.delegate = self;
    // 最多能选1张图片 这里 self.photoArr里面包含添加照片那个View
    NSInteger currentImgs = self.photoArr.count - 1;
    if (currentImgs >= kMaxUploads) {
        pickerVc.maxCount = 0;
    }else{
        pickerVc.maxCount =  kMaxUploads - currentImgs;
    }
    pickerVc.status = PickerViewShowStatusCameraRoll;
    [pickerVc showPickerVc:self];
    
}
#pragma mark - ZLPhotoPickerViewControllerDelegate
- (void)pickerViewControllerDoneAsstes:(NSArray *)assets{
    
    [self reloadFBImageViewWithPhotoAssets:assets];
}

#pragma mark - 拿到返回的照片创建imageView
- (void)reloadFBImageViewWithPhotoAssets:(NSArray *)assets {
    for (int i = 0; i < assets.count; i++) {
        [self createFBImageView:assets[i]];
    }
    [self refreshPhotosDisplayViewLayout];
}
- (void)createFBImageView:(id )asset {
    //添加到数组里面
    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(0, 0, kPhotoWidth, kPhotoWidth);
    imageView.contentMode = UIViewContentModeScaleToFill;
    imageView.userInteractionEnabled = YES;
    
    if ([asset isKindOfClass:[ZLPhotoAssets class]]) {
        imageView.image = [asset aspectRatioImage];
    }else if ([asset isKindOfClass:[NSString class]]){
        [imageView sd_setImageWithURL:[NSURL URLWithString:(NSString *)asset] placeholderImage:[UIImage imageNamed:@"mn_addImg"]];
    }else if ([asset isKindOfClass:[UIImage class]]){
        imageView.image = (UIImage *)asset;
    }else if ([asset isKindOfClass:[ZLCamera class]]){
        imageView.image = [asset thumbImage];
    }
    
    //添加进入图片数组
    [self.photoArr insertObject:imageView atIndex:0];
    //添加删除按钮
    [self createDeleteButtonOverSuperView:imageView];
}
- (void)createDeleteButtonOverSuperView:(UIImageView *)imageView {
    UIButton *deleteBtn = [UIButton buttonWithType:(UIButtonTypeCustom)];
    deleteBtn.frame = CGRectMake(imageView.width-30, 0, 30, 30);
    [deleteBtn setImage:[UIImage imageNamed:@"mn_deleteImg"] forState:UIControlStateNormal];
    [deleteBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteBtnClick:) forControlEvents:(UIControlEventTouchUpInside)];
    [imageView addSubview:deleteBtn];
}

- (void)deleteBtnClick:(UIButton *)sender {
    UIImageView *imageView = (UIImageView *)sender.superview;
    [self.photoArr removeObject:imageView];
    
    //刷新布局
    [self refreshPhotosDisplayViewLayout];
}

#pragma mark - 刷新照片的显示
- (void)refreshPhotosDisplayViewLayout {
    for (UIView *view in self.displayPhotoView.subviews) {
        [view removeFromSuperview];
    }
    for (int i = 0; i < self.photoArr.count; i++) {
        UIView *tmpView = (UIView *)self.photoArr[i];
        tmpView.frame = CGRectMake(i*(kPhotoWidth + 10)+10, 10, kPhotoWidth, kPhotoHeight);
        [self.displayPhotoView addSubview:tmpView];
        if (i >= kMaxUploads) {
            tmpView.hidden = YES;
        }else {
            tmpView.hidden = NO;
        }
    }
}

//把本地选中的图片转为Data
//- (void)imageToData:(UIImage *)image formData:(id<AFMultipartFormData>) formData{
//    NSData *imageData;
//    //判断图片格式
//    if(UIImagePNGRepresentation(image)){
//        imageData = UIImagePNGRepresentation(image);
//        [formData appendPartWithFileData:imageData name:@"image" fileName:@"feedback" mimeType:@"image/png"];
//        
//    }else if(UIImageJPEGRepresentation(image, 1)){
//        imageData = UIImageJPEGRepresentation(image,1);
//        [formData appendPartWithFileData:imageData name:@"image" fileName:@"feedback" mimeType:@"image/jpg"];
//    }
//}






@end
