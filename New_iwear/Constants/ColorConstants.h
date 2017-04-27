//
//  ColorConstants.h
//  OnePiece
//
//  Created by JustFei on 2016/11/9.
//  Copyright © 2016年 manridy. All rights reserved.
//

#ifndef ColorConstants_h
#define ColorConstants_h

/** rgb颜色转换（16进制->10进制）*/
#define COLOR_WITH_HEX(rgbValue ,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

/** 带有RGBA的颜色设置 */
#define COLOR_WITH_RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]

/** 透明色 */
#define CLEAR_COLOR [UIColor clearColor]

/** 常用颜色 */
#define WHITE_COLOR [UIColor whiteColor]
#define BLACK_COLOR [UIColor blackColor]
#define RED_COLOR [UIColor redColor]
#define BLUE_COLOR [UIColor blueColor]
#define GREEN_COLOR [UIColor greenColor]
#define GRAY_COLOR [UIColor grayColor]
#define ORANGE_COLOR [UIColor orangeColor]
#define PURPLE_COLOR [UIColor purpleColor]

/** 未连接时的背景颜色 */
#define DISCONNECT_BACKGROUND_COLOR COLOR_WITH_RGBA(46.0, 52.0, 62.0, 1)
/** 连接时的背景颜色 */
#define CONNECT_BACKGROUND_COLOR COLOR_WITH_RGBA(36.0, 154.0, 184.0, 1)

/** 未连接时的刻度盘颜色 */
#define DISCONNECT_DIAL_COLOR COLOR_WITH_RGBA(61.0, 66.0, 67.0, 1)
/** 连接时的刻度盘颜色 */
#define CONNECT_DIAL_COLOR COLOR_WITH_RGBA(124.0, 204.0, 218.0, 1)

/** navigationBar 的颜色 */
#define NAVIGATION_BAR_COLOR COLOR_WITH_HEX(0xfabe00, 1)

/** tableView 线的颜色 */
#define TABLEVIEW_LINE_COLOR COLOR_WITH_HEX(0xcccccc,1)

/** 按钮的绿色 */
//#define kButtonGreenColor COLOR_WITH_HEX(0x18db30,1)

#endif /* ColorConstants_h */
