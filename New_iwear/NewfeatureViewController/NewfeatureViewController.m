//
//  NewfeatureViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/6/27.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "NewfeatureViewController.h"
#import "MainViewController.h"

#define NewfeatureCount 3

@interface NewfeatureViewController ()<UIScrollViewDelegate>

@property (nonatomic,weak) UIPageControl *pageControl;

@end

@implementation NewfeatureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupScrollView];
    [self createSkipBt];
}

//创建UIScrollView并添加图片
- (void)setupScrollView
{
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.frame = [UIScreen mainScreen].bounds;
    [self.view addSubview:scrollView];
    
    scrollView.bounces = NO;
    scrollView.pagingEnabled = YES;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.contentSize = CGSizeMake(3*SCREEN_BOUNDS.size.width, 0);
    scrollView.delegate = self;
    
    for (NSInteger i = 0; i < NewfeatureCount; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.x = i * SCREEN_BOUNDS.size.width;
        imageView.y = 0;
        imageView.width = SCREEN_BOUNDS.size.width;
        imageView.height = SCREEN_BOUNDS.size.height;
        NSString *name = [NSString stringWithFormat:@"pic%ld",i+1];
        imageView.image = [UIImage imageNamed:name];
        [scrollView addSubview:imageView];
        if (i == NewfeatureCount - 1) {
            [self setupStartBtn:imageView];
        }
    }
    
    // 4.添加pageControl：分页，展示目前看的是第几页
    UIPageControl *pageControl = [[UIPageControl alloc] init];
    pageControl.numberOfPages = NewfeatureCount;
    pageControl.backgroundColor = [UIColor redColor];
    pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
    pageControl.pageIndicatorTintColor = COLOR_WITH_RGBA(189, 189, 189, 1);
//    KRGB(189, 189, 189);
    pageControl.centerX = SCREEN_BOUNDS.size.width * 0.5;
    pageControl.centerY = SCREEN_BOUNDS.size.height - 50;
    [self.view addSubview:pageControl];
    self.pageControl = pageControl;
}

//左上角的灰色跳过按钮
-(void)createSkipBt
{
    UIButton *skipBt = [UIButton buttonWithType:UIButtonTypeCustom];
    skipBt.frame = CGRectMake(SCREEN_BOUNDS.size.width - 90, 40, 80, 30);
    skipBt.backgroundColor = [UIColor colorWithRed:0.3 green:0.3f blue:0.3f alpha:0.3];
    [skipBt setTitle:@"跳过" forState:UIControlStateNormal];
    [skipBt setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    skipBt.layer.cornerRadius = 10;
    skipBt.clipsToBounds = YES;
    skipBt.tag = 10;
    [skipBt addTarget:self action:@selector(BtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:skipBt];
}

//手动拖拽结束时候调用
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    double page = scrollView.contentOffset.x / scrollView.frame.size.width;
    // 四舍五入计算出页码
    self.pageControl.currentPage = (int)(page + 0.5);
    // 1.3四舍五入 1.3 + 0.5 = 1.8 强转为整数(int)1.8= 1
    // 1.5四舍五入 1.5 + 0.5 = 2.0 强转为整数(int)2.0= 2
    // 1.6四舍五入 1.6 + 0.5 = 2.1 强转为整数(int)2.1= 2
    // 0.7四舍五入 0.7 + 0.5 = 1.2 强转为整数(int)1.2= 1
}

//给最后一张图片添加 进入问医生按钮
- (void)setupStartBtn:(UIImageView *)imgView
{
    imgView.userInteractionEnabled = YES;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setBackgroundImage:[UIImage imageNamed:@"cancel_ask"] forState:UIControlStateNormal];
//    btn.size = btn.currentBackgroundImage.size;
    btn.centerX = imgView.width * 0.5;
    btn.centerY = imgView.height * 0.75;
    [btn setTitle:@"开启健康生活" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(BtnDidClicked) forControlEvents:UIControlEventTouchUpInside];
    [imgView addSubview:btn];
}

//进入问医生按钮点击事件
-(void)BtnDidClicked
{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    MainViewController *vc = [[MainViewController alloc]init];
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
    
    //修改title颜色和font
    [nc.navigationBar setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont systemFontOfSize:15]}];
    window.rootViewController = nc;
}

@end
