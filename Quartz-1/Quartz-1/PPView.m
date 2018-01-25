//
//  PPView.m
//  QuartzDemo
//
//  Created by pp on 2018/1/8.
//  Copyright © 2018年 pp. All rights reserved.
//

#import "PPView.h"

@interface PPView()
@property (nonatomic, strong) UIImageView *imageView;
@end
@implementation PPView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.imageView = imageView;
        [self addSubview:imageView];
        [self draw1];
    }
    return self;
}

/**
 CoreGraphic API -> LLO坐标系

 CGBitmapContextCreate -> 创建 bitmap Context
 CGBitmapContextCreateImage -> 获取 bitmap Image CGImageRef -> 转化成UIImage

 用 CoreGraphic CGContextDrawImage    绘图
 */
-(void)draw1{
    // 1. 创建颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    int bitsPerComponent = 8;
    //RGBA(的bytes) * bitsPerComponent *width
    int bytesPerRow = 4 * 8 * bitsPerComponent * width;
    // 2. 创建bitmapContext, 使用Quartz创建的Context,因此坐标系是LLO, 坐标原点是左下角
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);

    // 3. 绘制背景
    CGContextFillRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 400, 400));
    CGContextStrokeRect(context, CGRectMake(0, 0, width, height));

    // 4. 获取UIKit图片, 并且使用Quartz绘制图片. 注意使用Quartz相关的api绘制图片时,只能传入UIImage的底层CGImage.
    //    并且此时由于绘制图片API `CGContextDrawImage` 是Quartz API, 因此绘制方法表示图片的坐标原点也是LLO
    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    CGContextDrawImage(context, CGRectMake(0, 0, 100, 100), img.CGImage);

    // 5. 从context中获取CGImage, 并创建UIImage
    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];

    // 6. 清理CoreGraphic 资源
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgimg);

    self.imageView.image = resultImg;
}

/**
 UIKit API -> ULO 原点

 UIGraphicsBeginImageContextWithOptions -> 创建bitmap Context, 并push 入 stack
 UIGraphicsGetImageFromCurrentImageContext -> 获取 bitmap

 */
-(void)draw2 {
    // 1. 创建 context, 并且将context push到UIKit维护的Context Stack
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    // 2. 创建Path, 绘制背景和填充颜色
    UIBezierPath *rect = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor redColor] setFill];
    [rect fill];
    [[UIColor greenColor] setStroke];
    [rect stroke];

    // 3. 后面使用 UIKit 的drawing method,因此需要坐标系是 ULO, 这里使用 UIKit方法创建, 因此绘制的文字都是正的. 坐标原点是ULO
    NSString *text= @"文字";
    UIFont *font=[UIFont systemFontOfSize:14];
    [text drawAtPoint:CGPointMake(100, 100) withAttributes:font.fontDescriptor.fontAttributes];

    // 4. 用UIKit 绘制图像, context是UIKit创建的, 因此是ULO坐标系,(0,0,100,100)在左上角,并且图片是正向
    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    // 5. 从当前context获取UIImage
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = resultImg;
}

/**
 CoreGraphic 创建 Context  -> LLO

 绘图使用 UIKit -> 需要将 其push 到context
 */
-(void)draw3_1 {
    // 1. 创建CGContext使用的颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    int bitsPerComponent = 8;
    //RGBA*8*width
    int bytesPerRow = 4 * 8 * bitsPerComponent * width;
    // 2. 使用Quartz API创建CGContext, 坐标系是 LLO
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);

    // 3. UIKit API的绘图方法. 需要首先将当前context push到 当前UIKit维护的context stack中!!!!!(此时绘图方法才知道绘制到哪个context)
    UIGraphicsPushContext(context);

    // 4. 填充颜色, 配置部分状态
    CGContextFillRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 400, 400));
    CGContextStrokeRect(context, CGRectMake(0, 0, width, height));
    [[UIColor redColor] setFill];

    // 5. 使用UIKit方法绘制文字.
    NSString *text= @"文字";
    UIFont *font=[UIFont systemFontOfSize:14];
    [text drawAtPoint:CGPointMake(100, 100) withAttributes:font.fontDescriptor.fontAttributes];

    // 6. 使用UIKit方法绘制图像
    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    // 7. 从当前context中获取UIImage
    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    UIGraphicsPopContext();

    // 8. 清理资源
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgimg);

    self.imageView.image = resultImg;
}

-(void)draw3_2 {
    // 1. 创建CGContext使用的颜色空间
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    int bitsPerComponent = 8;
    //RGBA*8*width
    int bytesPerRow = 4 * 8 * bitsPerComponent * width;
    // 2. 使用Quartz API创建CGContext, 坐标系是 LLO
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);

    // 3. UIKit API的绘图方法. 需要首先将当前context push到 当前UIKit维护的context stack中!!!!!(此时绘图方法才知道绘制到哪个context)
    UIGraphicsPushContext(context);

    // 4. 填充颜色, 配置部分状态
    CGContextFillRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 400, 400));
    CGContextStrokeRect(context, CGRectMake(0, 0, width, height));
    [[UIColor redColor] setFill];

    // 5. 在使用UIKit绘制方法进行绘制之前,先将当前context的坐标系调整成ULO, 具体步骤如下: 翻转画布 -> 先将画布向上移动 height, 然后将沿着y翻转坐标轴
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 6.1 使用UIKit方法绘制文字, 由于context的坐标系统已经是ULO.此时绘制的内容是通过ULO为坐标系的
    NSString *text= @"文字1";
    UIFont *font=[UIFont systemFontOfSize:14];
    [text drawAtPoint:CGPointMake(100, 100) withAttributes:font.fontDescriptor.fontAttributes];

    // 6.2. 使用UIKit方法绘制图像 ,同上
    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    // 6.3 还原之前的context的坐标系, 转化成 LLO
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 6.4 用UIKit 绘制文字和图片. 此时看的出来 坐标系是LLO, 图片和蚊子位置正确. 具体表现同 3-1
    text= @"文字2";
    [text drawAtPoint:CGPointMake(100, 100) withAttributes:font.fontDescriptor.fontAttributes];
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    // 7. 从当前context中获取UIImage
    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    UIGraphicsPopContext();

    // 8. 清理资源
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgimg);

    self.imageView.image = resultImg;
}


/**
 使用UIKit创建的bitmap Context: 坐标系是 ULO

 此时使用CoreGraphic 绘制方法. 绘制出来的 图是倒置的. (通过平移 height, 翻转 y, 可以得到正图)

 在绘制前.需要将 坐标系 转化成 LLO
 */
-(void)draw4_1{

    // 1. UIKit方法会创建Context, 并且将该Context push到UIKit维护的Context stack, 并且UIKit会自动将Context的坐标调整为ULO,
    /*
     UIGraphicsBeginImageContextWithOptions() 相当于 Quartz 以下API:
        1. CGBitmapContextCreate -> 创建 CGContext
        2. UIGraphicsPushContext(context) -> 将context push进入UIKit的 context stack
        3. CGContextTranslateCTM(context, 0, height); CGContextScaleCTM(context, 1.0, -1.0);  -> 调整context的坐标系为ULO
     */
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    // 2. UIKit 的相关方法填充背景. 绘制边界
    UIBezierPath *rect = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor redColor] setFill];
    [rect fill];
    [[UIColor greenColor] setStroke];
    [rect stroke];

    // 3. UIKit通过`UIGraphicsGetCurrentContext`获取 CGContext 对象(Quartz API使用)
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 4. Quartz 的绘制方法, 要求Context坐标系是LLO, 此时和当前context不匹配. 绘制是倒置的图像
    UIImage *img = [UIImage imageNamed:@"1.jpg"];
    CGContextDrawImage(context, CGRectMake(0, 0, 100, 100), img.CGImage);

    
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    // 5 清理Context
    UIGraphicsEndImageContext();

    self.imageView.image = resultImg;
}

-(void)draw4_2{

    // 1. UIKit方法会创建Context, 并且将该Context push到UIKit维护的Context stack, 并且UIKit会自动将Context的坐标调整为ULO,
    /*
     UIGraphicsBeginImageContextWithOptions() 相当于 Quartz 以下API:
     1. CGBitmapContextCreate -> 创建 CGContext
     2. UIGraphicsPushContext(context) -> 将context push进入UIKit的 context stack
     3. CGContextTranslateCTM(context, 0, height); CGContextScaleCTM(context, 1.0, -1.0);  -> 调整context的坐标系为ULO
     */
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    // 2. UIKit 的相关方法填充背景. 绘制边界
    UIBezierPath *rect = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor redColor] setFill];
    [rect fill];
    [[UIColor greenColor] setStroke];
    [rect stroke];

    // 3. UIKit通过`UIGraphicsGetCurrentContext`获取 CGContext 对象(Quartz API使用)
    CGContextRef context = UIGraphicsGetCurrentContext();


    // 4. 在调用Quartz方法绘制之前,需要将 坐标系满足 LLO
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 5.1 具体的Quartz 绘制方法, 此时绘制的图像位于左下角
    // CGContextDrawXXXX 方法 -> 会以 Context 的LLO为坐标系
    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    CGContextDrawImage(context, CGRectMake(0, 0, 100, 100), img.CGImage);


    // 5.2 将context坐标重新转化成ULO, 然后继续绘制. 绘制的图像位于左上角
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();

    // 6 清理Context
    UIGraphicsEndImageContext();
    self.imageView.image = resultImg;
}


/**
 绘制渐变色
 */
-(void)draw5{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    int bitsPerComponent = 8;
    //RGBA(的bytes) * bitsPerComponent *width
    int bytesPerRow = 4 * 8 * bitsPerComponent * width;
    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);

    //画布透明
    CGContextFillRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 400, 400));
    CGContextStrokeRect(context, CGRectMake(0, 0, width, height));

    CGColorSpaceRef myColorspace;
    CGFloat locations[2] = {0.0, 0.5};
    myColorspace = CGColorSpaceCreateDeviceRGB();
    NSMutableArray *array = [NSMutableArray array];
    [array addObject:(id)[UIColor greenColor].CGColor];
    [array addObject:(id)[UIColor redColor].CGColor];
    [array addObject:(id)[UIColor blueColor].CGColor];


    CGGradientRef gradientRef = CGGradientCreateWithColors(myColorspace, (__bridge CFArrayRef)array, NULL);

    CGPoint myStartPoint, myEndPoint;
    myStartPoint.x = 0.0;
    myStartPoint.y = 0.0;
    myEndPoint.x = 0;
    myEndPoint.y = height;
    CGContextDrawLinearGradient(context, gradientRef, myStartPoint, myEndPoint, 0);

    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgimg);

    self.imageView.image = resultImg;
}


/**
 drawRect 会帮我们做如下事情(类似于UIGraphicsBeginImageContextWithOptions,但产生的context并非 bitmapContext):
    1. 创建一个context(注意这个context 并非 BitmapContext, 也就是说绘制的目的不是得到绘制图片, 而是直接渲染在view底层的layer 的content上)
    2. 会隐士调用UIGraphicsPushContext(context), 将这个创建的 context push 进入UIKit context stack
    3. 自动帮我们调整context坐标系是ULO

 */
//- (void)drawRect:(CGRect)rect {
//    // 1. 直接通过UIKit API 获取当前的绘制所在的context
//    CGContextRef context = UIGraphicsGetCurrentContext();
//
//    // 2. 设置背景等等
//    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//    CGContextFillRect(context, rect);
//
//    // 3. 使用UIKit API 进行绘制
//    UIImage *img = [UIImage imageNamed:@"1.jpg"];
//    [img drawInRect:CGRectMake(0, 0, 100, 100)];
//    NSString *text = @"文字";
//    UIFont *font = [UIFont systemFontOfSize:14];
//    [text drawAtPoint:CGPointMake(100, 100) withAttributes:font.fontDescriptor.fontAttributes];
//
//    // ps: 无需清理
//}


@end
