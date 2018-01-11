//
//  ViewController.m
//  Quartz-1
//
//  Created by pp on 2018/1/11.
//  Copyright © 2018年 pp. All rights reserved.
//

#import "ViewController.h"
#import "PPView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor lightGrayColor];
    PPView *view = [[PPView alloc] initWithFrame:CGRectMake(0, 0, 300, 300)];
    view.center = self.view.center;
    [self.view addSubview:view];

}

@end
