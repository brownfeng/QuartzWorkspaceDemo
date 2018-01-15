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
        [self draw5];
    }
    return self;
}

/**
 CoreGraphic API -> LLO

 CGBitmapContextCreate -> 创建 bitmap Context
 CGBitmapContextCreateImage -> 获取 bitmap Image CGImageRef -> 转化成UIImage

 用 CoreGraphic CGContextDrawImage    绘图
 */
-(void)draw1{
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

    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    CGContextDrawImage(context, CGRectMake(0, 0, 100, 100), img.CGImage);

    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];

    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(cgimg);

    self.imageView.image = resultImg;
}

/**
 UIKit API -> ULO

 UIGraphicsBeginImageContextWithOptions -> 创建bitmap Context
 UIGraphicsGetImageFromCurrentImageContext -> 获取 bitmap

 用 UIKit API 绘图:

 使用UIKit 绘图. 只能将  context push 成为当前上下文!!!!!!
 */
-(void)draw2 {
    // 1. 创建 context, 2. push到Context Stack
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    //画布透明
    UIBezierPath *rect = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor redColor] setFill];
    [rect fill];
    [[UIColor greenColor] setStroke];
    [rect stroke];

    // 后面使用 UIKit 的drawing method,因此需要坐标系是 ULO, 这里使用 UIKit方法创建, 因此坐标系满足
    NSString *text= @"文字";
    UIFont *font=[UIFont systemFontOfSize:14];

    // 绘制方法!!!!!
    [text drawAtPoint:CGPointMake(100, 200) withAttributes:font.fontDescriptor.fontAttributes];

    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    // 绘制方法!!!!!
    [img drawInRect:CGRectMake(0, 0, 100, 100)];

    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.imageView.image = resultImg;
}

/**
 CoreGraphic 创建 Context  -> LLO

 绘图使用 UIKit -> 需要将 其push 到context
 由于UIKit 默认使用 ULO 坐标系. 因此. 调用context 前.需要将context坐标系CTM更新成 ULO
 */
-(void)draw3 {
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    float width = self.bounds.size.width;
    float height = self.bounds.size.height;
    int bitsPerComponent = 8;
    //RGBA*8*width
    int bytesPerRow = 4 * 8 * bitsPerComponent * width;

    CGContextRef context = CGBitmapContextCreate(NULL, width, height, bitsPerComponent, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);

    // 后面使用UIKit的方法进行计算 -> 一定需要Context的坐标系是ULO, 否则绘制的图形是倒置的
    //翻转画布 -> 先将画布向上移动 height, 然后将沿着y翻转坐标轴
    CGContextTranslateCTM(context, 0, height);
    CGContextScaleCTM(context, 1.0, -1.0);

    //为了使用UIKit 的绘图方法.需要将context push到 当前UIKit维护的context stack中
    UIGraphicsPushContext(context);

    //画布透明
    CGContextFillRect(context, self.bounds);
    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
    CGContextSetRGBStrokeColor(context, 0, 1, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, 400, 400));
    CGContextStrokeRect(context, CGRectMake(0, 0, width, height));
    [[UIColor redColor] setFill];
    NSString *text= @"文字";
    UIFont *font=[UIFont systemFontOfSize:14];
    [text drawAtPoint:CGPointMake(100, 200) withAttributes:font.fontDescriptor.fontAttributes];

    UIImage *img=[UIImage imageNamed:@"1.jpg"];

    // 绘制方法!!!
    [img drawInRect:CGRectMake(0, 0, 100, 100)];


    CGImageRef cgimg = CGBitmapContextCreateImage(context);
    UIImage *resultImg = [UIImage imageWithCGImage:cgimg];
    UIGraphicsPopContext();

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
-(void)draw4{

    // UIKit 会最后做一件事情
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    CGContextRef context = UIGraphicsGetCurrentContext();

    UIBezierPath *rect = [UIBezierPath bezierPathWithRect:self.bounds];
    [[UIColor redColor] setFill];
    [rect fill];
    [[UIColor greenColor] setStroke];
    [rect stroke];

    UIImage *img=[UIImage imageNamed:@"1.jpg"];
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);

    // 绘制方法!!!!!
    // CGContextDrawXXXX 方法 -> 会以 Context 的LLO为坐标系
    CGContextDrawImage(context, CGRectMake(0, 0, 100, 100), img.CGImage);
    CGContextTranslateCTM(context, 0, self.bounds.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    [img drawInRect:CGRectMake(100, 0, 100, 100)];

    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    self.imageView.image = resultImg;
}

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

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextTranslateCTM(context, 0, rect.size.height);
////    CGContextScaleCTM(context, 1.0, -1.0);
//
//
//    CGContextSetRGBFillColor(context, 1, 0, 0, 1);
//    CGContextFillRect(context, rect);
//
//
////    CGContextTranslateCTM(context, 0, rect.size.height);
////    CGContextScaleCTM(context, 1.0, -1.0);
//
//
//    UIImage *img=[UIImage imageNamed:@"1.jpg"];
//    // 绘制方法!!!!!
//    [img drawInRect:CGRectMake(0, 0, 100, 100)];
//    NSString *text = @"文字";
//    UIFont *font = [UIFont systemFontOfSize:14];
//    [text drawInRect:rect withAttributes:font.fontDescriptor.fontAttributes];
//}


@end
