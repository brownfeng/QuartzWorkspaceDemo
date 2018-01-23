//
//  ViewController.m
//  Quartz-2
//
//  Created by pp on 2018/1/11.
//  Copyright © 2018年 pp. All rights reserved.
//

#import "Bezier.h"
#import "ViewController.h"
#import "Drawing-Gradient.h"
#import "Drawing-Block.h"

#define ScreenHeight MAX([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width)//获取屏幕高度，兼容性测试
#define ScreenWidth  MIN([[UIScreen mainScreen] bounds].size.height,[[UIScreen mainScreen] bounds].size.width)//获取屏幕宽度，兼容性测试

@interface ViewController ()
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, assign) CGRect maskFrameRect;

@property (nonatomic, strong) Gradient *gradient;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor grayColor];
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];


    UIColor *fromColor = [UIColor redColor];
    UIColor *toColor = [UIColor greenColor];
    self.gradient = [Gradient gradientFrom:fromColor to:toColor];

    CGRect targetRect = self.imageView.frame;
    CGRect inset = CGRectInset((CGRect)targetRect, 100, 100);

    self.maskFrameRect = inset;



    UIImage *image = [self buildInversions2:self.imageView.bounds.size];
    self.imageView.image = image;

    [self writeImageToDoc:image withName:@"complete"];
}

// Demonstrating the various kinds of path inversions
- (UIImage *) buildInversions2: (CGSize) targetSize
{
    // 初始化
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = (CGRect){.size = targetSize};
//    CGRect inset = CGRectInset((CGRect)targetRect, 30, 30);
    [[UIColor clearColor] setFill];
    UIRectFill(targetRect);

    // 菊花图 path
    UIBezierPath *path = [self bezierPath];
    // 将菊花图 path 移动到 inset 中心
    CGPoint position = RectGetCenter(targetRect);
    position.y = position.y * 4 / 5;
    FitPathToRect(path, self.maskFrameRect);

    MovePathCenterToPoint(path, position);

    PushDraw(^{
        [path.inverse addClip];

        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(0, targetSize.height);
        [self.gradient drawFrom:p1 toPoint:p2 style:kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation];
    });


    {
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self writeImageToDoc:image withName:@"2"];
    }

    //方法2
    [path setLineWidth:5.0];

    {
    // 另外一个直接将线条加粗
    [[UIColor redColor] setStroke];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self writeImageToDoc:image withName:@"3"];
    }

    {
    // 另外一个直接将线条加粗
    [[UIColor whiteColor] setStroke];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self writeImageToDoc:image withName:@"4"];
    }

    {
    // 另外一个直接将线条加粗
    [[UIColor blueColor] setStroke];
    [path stroke];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self writeImageToDoc:image withName:@"5"];
    }
    

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIBezierPath *)bezierPath {
    //// Clip Path
    UIBezierPath* pathPath = [UIBezierPath bezierPath];
    [pathPath moveToPoint: CGPointMake(16.72, 157.8)];
    [pathPath addCurveToPoint: CGPointMake(47.05, 49.65) controlPoint1: CGPointMake(16.72, 157.8) controlPoint2: CGPointMake(7.55, 95.28)];
    [pathPath addCurveToPoint: CGPointMake(160.47, 0.02) controlPoint1: CGPointMake(86.56, 4.01) controlPoint2: CGPointMake(132.98, 0.02)];
    [pathPath addCurveToPoint: CGPointMake(272.23, 49.65) controlPoint1: CGPointMake(187.96, 0.02) controlPoint2: CGPointMake(232.93, 4.52)];
    [pathPath addCurveToPoint: CGPointMake(304.16, 158.08) controlPoint1: CGPointMake(311.52, 94.77) controlPoint2: CGPointMake(304.16, 158.08)];
    [pathPath addCurveToPoint: CGPointMake(318.09, 203.54) controlPoint1: CGPointMake(304.16, 158.08) controlPoint2: CGPointMake(327.29, 163.98)];
    [pathPath addCurveToPoint: CGPointMake(293.55, 250.17) controlPoint1: CGPointMake(308.9, 243.09) controlPoint2: CGPointMake(293.55, 250.17)];
    [pathPath addCurveToPoint: CGPointMake(239.8, 338.53) controlPoint1: CGPointMake(293.55, 250.17) controlPoint2: CGPointMake(277.8, 304.78)];
    [pathPath addCurveToPoint: CGPointMake(162.17, 369.4) controlPoint1: CGPointMake(201.8, 372.27) controlPoint2: CGPointMake(162.17, 369.4)];
    [pathPath addCurveToPoint: CGPointMake(81.48, 338.53) controlPoint1: CGPointMake(162.17, 369.4) controlPoint2: CGPointMake(120.01, 375.39)];
    [pathPath addCurveToPoint: CGPointMake(30.5, 251.45) controlPoint1: CGPointMake(42.95, 301.66) controlPoint2: CGPointMake(30.5, 251.45)];
    [pathPath addCurveToPoint: CGPointMake(0.96, 203.54) controlPoint1: CGPointMake(30.5, 251.45) controlPoint2: CGPointMake(6.27, 245.8)];
    [pathPath addCurveToPoint: CGPointMake(16.72, 157.8) controlPoint1: CGPointMake(-4.36, 161.27) controlPoint2: CGPointMake(16.72, 157.8)];
    [pathPath closePath];
    return pathPath;
}

-(void)writeImageToDoc:(UIImage *)image withName:(NSString *)imageName{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *fileName = [NSString stringWithFormat:@"%@.png",imageName];
        NSString  *pngPath = [NSTemporaryDirectory() stringByAppendingPathComponent:fileName];
        //    NSString  *jpgPath = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/Test.jpg"];

        // Write a UIImage to JPEG with minimum compression (best quality)
        // The value 'image' must be a UIImage object
        // The value '1.0' represents image compression quality as value from 0.0 to 1.0
        //    [UIImageJPEGRepresentation(image, 1.0) writeToFile:jpgPath atomically:YES];

        // Write image to PNG
        [UIImagePNGRepresentation(image) writeToFile:pngPath atomically:YES];
    });
}



@end
