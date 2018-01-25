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
    self.view.backgroundColor = [UIColor whiteColor];
    self.imageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];

    UIColor *fromColor = [UIColor redColor];
    UIColor *toColor = [UIColor greenColor];
    self.gradient = [Gradient gradientFrom:fromColor to:toColor];

    self.maskFrameRect = CGRectMake(0, 0, 300, 300);

    UIImage *image = [self buildInversions2:self.imageView.bounds.size];
    self.imageView.image = image;
}

// Demonstrating the various kinds of path inversions
- (UIImage *) buildInversions2: (CGSize) targetSize
{
    // 初始化
    UIGraphicsBeginImageContextWithOptions(targetSize, NO, 0.0);
    CGRect targetRect = (CGRect){.size = targetSize};

    [[UIColor clearColor] setFill];
    UIRectFill(targetRect);

    // 菊花图 path
    UIBezierPath *path = [self bezierPath];
    // 将菊花图 path 移动到 inset 中心
    CGPoint position = RectGetCenter(targetRect);
    FitPathToRect(path, self.maskFrameRect);

    MovePathCenterToPoint(path, position);

    PushDraw(^{
        [path.inverse addClip];

        CGPoint p1 = CGPointMake(0, 0);
        CGPoint p2 = CGPointMake(0, targetSize.height);
        [self.gradient drawFrom:p1 toPoint:p2 style:kCGGradientDrawsAfterEndLocation | kCGGradientDrawsBeforeStartLocation];
    });

    PushDraw(^{
        [[UIColor blackColor] set];
        UIBezierPath *roundPath = [UIBezierPath bezierPathWithRect:PathBoundingBox(path)];
        [roundPath stroke];
    });

    // 另外一个直接将线条加粗
    [[UIColor whiteColor] setStroke];
    [path stroke];
    

    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIBezierPath *)bezierPath {
    UIBezierPath* pathPath = [UIBezierPath bezierPath];
    [pathPath moveToPoint: CGPointMake(123.87, 0.33)];
    [pathPath addCurveToPoint: CGPointMake(176, 55.09) controlPoint1: CGPointMake(123.87, 0.33) controlPoint2: CGPointMake(157.86, 19.55)];
    [pathPath addCurveToPoint: CGPointMake(184.49, 125.31) controlPoint1: CGPointMake(194.15, 90.63) controlPoint2: CGPointMake(184.49, 125.31)];
    [pathPath addCurveToPoint: CGPointMake(198.82, 151.62) controlPoint1: CGPointMake(184.49, 125.31) controlPoint2: CGPointMake(194.74, 137.9)];
    [pathPath addCurveToPoint: CGPointMake(198.82, 178.86) controlPoint1: CGPointMake(202.89, 165.35) controlPoint2: CGPointMake(198.82, 178.86)];
    [pathPath addCurveToPoint: CGPointMake(187.11, 165.78) controlPoint1: CGPointMake(198.82, 178.86) controlPoint2: CGPointMake(194.39, 171.6)];
    [pathPath addCurveToPoint: CGPointMake(171.75, 161.42) controlPoint1: CGPointMake(179.83, 159.95) controlPoint2: CGPointMake(171.75, 161.42)];
    [pathPath addCurveToPoint: CGPointMake(154.86, 165.78) controlPoint1: CGPointMake(171.75, 161.42) controlPoint2: CGPointMake(166.11, 160.38)];
    [pathPath addCurveToPoint: CGPointMake(133.83, 175.04) controlPoint1: CGPointMake(143.62, 171.18) controlPoint2: CGPointMake(133.83, 175.04)];
    [pathPath addCurveToPoint: CGPointMake(88.54, 177.05) controlPoint1: CGPointMake(133.83, 175.04) controlPoint2: CGPointMake(114.72, 182.08)];
    [pathPath addCurveToPoint: CGPointMake(41.29, 157.75) controlPoint1: CGPointMake(62.37, 172.02) controlPoint2: CGPointMake(41.29, 157.75)];
    [pathPath addCurveToPoint: CGPointMake(22.36, 142.14) controlPoint1: CGPointMake(41.29, 157.75) controlPoint2: CGPointMake(34.53, 154.56)];
    [pathPath addCurveToPoint: CGPointMake(0.04, 115.32) controlPoint1: CGPointMake(10.18, 129.71) controlPoint2: CGPointMake(0.04, 115.32)];
    [pathPath addCurveToPoint: CGPointMake(44.26, 137.51) controlPoint1: CGPointMake(0.04, 115.32) controlPoint2: CGPointMake(27.4, 132.89)];
    [pathPath addCurveToPoint: CGPointMake(80.01, 139.88) controlPoint1: CGPointMake(61.11, 142.14) controlPoint2: CGPointMake(80.01, 139.88)];
    [pathPath addCurveToPoint: CGPointMake(98.37, 137.51) controlPoint1: CGPointMake(80.01, 139.88) controlPoint2: CGPointMake(92.48, 139.46)];
    [pathPath addCurveToPoint: CGPointMake(112.82, 129) controlPoint1: CGPointMake(104.26, 135.56) controlPoint2: CGPointMake(112.82, 129)];
    [pathPath addCurveToPoint: CGPointMake(67.8, 86.54) controlPoint1: CGPointMake(112.82, 129) controlPoint2: CGPointMake(94.31, 112.93)];
    [pathPath addCurveToPoint: CGPointMake(18.99, 26.76) controlPoint1: CGPointMake(41.29, 60.14) controlPoint2: CGPointMake(18.99, 26.76)];
    [pathPath addCurveToPoint: CGPointMake(64.71, 63.74) controlPoint1: CGPointMake(18.99, 26.76) controlPoint2: CGPointMake(49.4, 52.21)];
    [pathPath addCurveToPoint: CGPointMake(98.37, 86.54) controlPoint1: CGPointMake(80.01, 75.26) controlPoint2: CGPointMake(98.37, 86.54)];
    [pathPath addCurveToPoint: CGPointMake(70.49, 55.09) controlPoint1: CGPointMake(98.37, 86.54) controlPoint2: CGPointMake(85.81, 73.75)];
    [pathPath addCurveToPoint: CGPointMake(44.26, 16.75) controlPoint1: CGPointMake(55.17, 36.43) controlPoint2: CGPointMake(44.26, 16.75)];
    [pathPath addCurveToPoint: CGPointMake(94.1, 62.08) controlPoint1: CGPointMake(44.26, 16.75) controlPoint2: CGPointMake(77.08, 48.42)];
    [pathPath addCurveToPoint: CGPointMake(141.42, 94.74) controlPoint1: CGPointMake(111.12, 75.74) controlPoint2: CGPointMake(141.42, 94.74)];
    [pathPath addCurveToPoint: CGPointMake(145.4, 49.61) controlPoint1: CGPointMake(141.42, 94.74) controlPoint2: CGPointMake(148.4, 72.99)];
    [pathPath addCurveToPoint: CGPointMake(123.87, 0.33) controlPoint1: CGPointMake(142.4, 26.22) controlPoint2: CGPointMake(123.87, 0.33)];
    [pathPath closePath];

    return pathPath;
}


@end
