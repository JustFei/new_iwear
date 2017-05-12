//
//  StepContentView.h
//  ManridyApp
//
//  Created by JustFei on 16/9/26.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StepTargetViewController.h"
#import "BleManager.h"
#import "PNChart.h"
//#import "FMDBTool.h"
#import "StepDataModel.h"

@interface StepContentView : UIView < PNChartDelegate >

@property (nonatomic ,strong) BleManager *myBleManager;

@property (nonatomic, assign) CGFloat progress;

//创建全局属性
@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic ,strong) NSTimer *timer;

//@property (nonatomic ,strong) FMDBTool *myFmdbTool;

@property (nonatomic ,strong) NSMutableArray *dateArr;
@property (nonatomic ,strong) NSMutableArray *dataArr;



- (void)drawProgress:(CGFloat )progress;
- (void)showChartView;

@end
