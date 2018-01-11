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
    UIColor *darkGray = [UIColor colorWithWhite:0.333 alpha:0.8];
    UIColor *black = [UIColor colorWithWhite:0.0 alpha:0.8];
    self.gradient = [Gradient gradientFrom:darkGray to:black];
    //    self.gradient = [Gradient gradientUsingInterpolationBlock:^CGFloat(CGFloat percent) {
    //        return EaseInOut(percent, 3);
    //    } between:darkGray and:black];
    self.maskFrameRect = CGRectMake(0, 0, 300, 300);
    self.view.backgroundColor = [UIColor whiteColor];

    //添加launchView
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    UIImage *image = [self buildInversions2:self.imageView.bounds.size];
    self.imageView.image = image;

}

// Demonstrating the various kinds of path inversions
- (UIImage *) buildInversions2: (CGSize) targetSize
{
    // 初始化
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 60, 60);
    [[UIColor clearColor] setFill];
    UIRectFill(targetRect);

    // 菊花图 path
    UIBezierPath *path = [self bezierPath];
    // 将菊花图 path 移动到 inset 中心
    FitPathToRect(path, self.maskFrameRect);
    MovePathCenterToPoint(path, RectGetCenter(inset));

    PushDraw(^{
        [path.inverse addClip];
        CGPoint p1 = RectGetPointAtPercents(path.bounds, 0.0, 0.0);
        CGPoint p2 = RectGetPointAtPercents(path.bounds, 0.0, 1.0);
        // 默认绘制时候 选择options: kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation
        [self.gradient drawFrom:p1 toPoint:p2];
    });


    // 方法1 为了不对后面的path产生影响. 创建一个新的path
    PushDraw(^{
        // 后面版本有一个 clipToStroke方法
        CGPathRef pat = path.CGPath;
        int width = 5;
        // CGPathCreateCopyByStrokingPath: Creates a stroked copy of another path.

        // 可以创建 一个path 通过stroke绘制时候的 边缘 path!!!!!!!!!
        CGPathRef pathRef = CGPathCreateCopyByStrokingPath(pat, NULL, width, kCGLineCapButt, kCGLineJoinMiter, 4);
        UIBezierPath *clipPath = [UIBezierPath bezierPathWithCGPath:pathRef];
        CGPathRelease(pathRef);
        [clipPath addClip];
        [[UIColor redColor] setFill];
        [clipPath fill];

        //        [self.gradient drawBottomToTop:path.bounds];

    });

    //方法2
    //    PushDraw(^{
    //        // 另外一个直接将线条加粗
    //        [path setLineWidth:5.0];
    //        [[UIColor redColor] setStroke];
    //        [path stroke];
    //    });

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



- (void)viewDidLoad1 {
    [super viewDidLoad];
    self.maskFrameRect = CGRectMake(0, 0, 300, 300);
    self.view.backgroundColor = [UIColor redColor];

    //添加launchView
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    self.imageView.image = [self buildInversions:self.imageView.bounds.size];
}

- (void)viewDidLoad2 {
    [super viewDidLoad];
    self.maskFrameRect = CGRectMake(0, 0, 300, 300);
    self.view.backgroundColor = [UIColor redColor];

    //添加launchView
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];

    CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
    gradientLayer.bounds = self.view.bounds;
    gradientLayer.position = self.imageView.center;
    gradientLayer.startPoint = CGPointMake(0.0f, 0.0f);
    gradientLayer.endPoint = CGPointMake(0.0f, 1.0f);
    gradientLayer.colors = @[ (__bridge id)[UIColor darkGrayColor].CGColor,(__bridge id)[UIColor blackColor].CGColor];
    gradientLayer.type = kCAGradientLayerAxial;
    [self.imageView.layer addSublayer:gradientLayer];

    UIBezierPath *path = [self bezierPath];
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc]init];
    shapeLayer.path = path.CGPath;
    CGRect bounds = CGPathGetBoundingBox(shapeLayer.path);
    NSLog(@"%@", NSStringFromCGRect(bounds));
    shapeLayer.bounds = bounds;
    shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    shapeLayer.position = self.view.center;
    [self.imageView.layer addSublayer:shapeLayer];

}




// Demonstrating the various kinds of path inversions
- (UIImage *) buildInversions: (CGSize) targetSize
{
    // 初始化
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);

    CGRect targetRect = SizeMakeRect(targetSize);
    CGRect inset = CGRectInset((CGRect)targetRect, 60, 60);
    [[UIColor clearColor] setFill];
    UIRectFill(targetRect);

    // 菊花图 path
    UIBezierPath *path = [self bezierPath];
    // 将菊花图 path 移动到 inset 中心
    FitPathToRect(path, self.maskFrameRect);
    MovePathCenterToPoint(path, RectGetCenter(inset));

    [path fill:[UIColor clearColor]];//给菊花path 填充颜色
    [path.inverse fill:[UIColor grayColor]];

    [path.inverse addClip];
    UIImage *i = [UIImage imageNamed:@"image.jpg"];
    [i drawInRect:targetRect];

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



@end