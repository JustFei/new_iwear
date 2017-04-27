//
//  StepCircleView.m
//  MiStepViewDemo
//
//  Created by Faith on 2017/4/20.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "StepCircleView.h"

#define kBorderWith 1
#define kViewWith self.bounds.size.width

@implementation StepCircleView

- (void)startCircleAnimation
{
    [self.point.layer addAnimation:[self coverDotAnimation] forKey:@"dotAnimation"];
}

- (CAKeyframeAnimation *)coverDotAnimation
{
    CGFloat startAngle = -(CGFloat)(M_PI_2);
    CGFloat endAngle = (CGFloat)(M_PI * 1.5);
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    animation.duration = 1;
    animation.path = [self circlePathWithstartAngle:startAngle endAngle:endAngle].CGPath;
    animation.calculationMode = kCAAnimationLinear;
    CAMediaTimingFunction *fn = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionLinear];
    animation.timingFunctions = @[fn];
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    animation.repeatCount = 8;
    
    return animation;
}

- (UIBezierPath *)circlePathWithstartAngle:(CGFloat)startAngle endAngle:(CGFloat)endAngle
{
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.bounds.size.width / 2, self.bounds.size.width / 2) radius:(CGFloat)(self.bounds.size.width - kBorderWith * 2) / 2 startAngle:startAngle endAngle:endAngle clockwise:true];
    return path;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
    //绘制圆环
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGRect bigRect = CGRectMake(rect.origin.x + kBorderWith,
                                rect.origin.y+ kBorderWith,
                                rect.size.width - kBorderWith*2,
                                rect.size.height - kBorderWith*2);
    
    //设置空心圆的线条宽度
    CGContextSetLineWidth(ctx, 1);
    //以矩形bigRect为依据画一个圆
    CGContextAddEllipseInRect(ctx, bigRect);
    //填充当前绘画区域的颜色
    [DISCONNECT_DIAL_COLOR set];
    //(如果是画圆会沿着矩形外围描画出指定宽度的（圆线）空心圆)/（根据上下文的内容渲染图层）
    CGContextStrokePath(ctx);
    
    //绘制刻度环
    CGFloat radius = (rect.size.width - kBorderWith * 2) / 2 - 10;
    //设置空心圆的线条宽度
    for (float i = 1.0; i <= 240; i ++) {
        CGContextSetLineWidth(ctx, 2);
        CGPoint centerPoint = CGPointMake(kViewWith / 2, kViewWith / 2);
        CGFloat angle = (CGFloat)(i / 240) * M_PI * 2;
        CGFloat startx = (radius - 10) * cos(angle);
        CGFloat starty = (radius - 10) * sin(angle);
        //NSLog(@"startx = %f, startx = %f, angle = %f",startx ,starty ,angle);
        
        CGContextMoveToPoint(ctx, centerPoint.x + startx, centerPoint.y + starty);
        CGFloat endx = radius * cos(angle);
        CGFloat endy = radius * sin(angle);
        //NSLog(@"x = %f, y = %f, angle = %f",endx ,endy ,angle);
        
        CGContextAddLineToPoint(ctx, centerPoint.x + endx, centerPoint.y + endy);
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    //加入圆点
    self.point = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle_point"]];
    self.point.frame = CGRectMake(0, 0, 32, 32);
    self.point.center = CGPointMake(bigRect.size.width / 2 + kBorderWith, bigRect.origin.y);
    [self addSubview:self.point];
    
}

@end
