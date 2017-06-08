//
//  FMDBManager.m
//  ManridyApp
//
//  Created by JustFei on 16/10/9.
//  Copyright © 2016年 Manridy.Bobo.com. All rights reserved.
//

#import "FMDBManager.h"
#import "ClockModel.h"
#import "SportModel.h"
#import "HeartRateModel.h"
#import "UserInfoModel.h"
#import "SleepModel.h"
#import "BloodModel.h"
#import "BloodO2Model.h"
#import "SedentaryModel.h"
#import "SegmentedStepModel.h"

@implementation FMDBManager

static FMDatabase *_fmdb;

#pragma mark - init
/**
 *  创建数据库文件
 *
 *  @param path 数据库名字，以用户名+MotionData命名
 *
 */
- (instancetype)initWithPath:(NSString *)path
{
    self = [super init];
    
    if (self) {
        NSString *filepath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:[NSString stringWithFormat:@"/%@.sqlite",path]];
        _fmdb = [FMDatabase databaseWithPath:filepath];
        
        NSLog(@"数据库路径 == %@", filepath);
        
        if ([_fmdb open]) {
            NSLog(@"数据库打开成功");
        }
        
//        //UserInfoData
//        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists UserInfoData(id integer primary key, username text, gender text, age integer, height integer, weight integer, steplength integer, steptarget integer, sleeptarget integer);"]];
        
//        //ClockData
//        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists ClockData(id integer primary key, time text, isopen bool);"]];

        //MotionData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists MotionData(id integer primary key, date text, step text, kCal text, mileage text, currentDataCount integer, sumDataCount integer);"]];
        
        //SegmentStepData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SegmentStepData(id integer primary key, date text, CHCount integer, AHCount integer, stepNumber text, kCalNumber text, mileageNumber text, startTime text, timeInterval integer);"]];
        
        //HeartRateData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists HeartRateData(id integer primary key, month text, date text, time text, heartRate text);"]];
        
        //BloodData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists BloodData(id integer primary key,month text, day text, time text, highBlood text, lowBlood text, currentCount text, sumCount text, bpm text);"]];
        
        //BloodO2Data
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists BloodO2Data(id integer primary key,month text, day text, time text, bloodO2integer text, bloodO2float text, currentCount text, sumCount text);"]];
        
        //SleepData
        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SleepData(id integer primary key,date text, startTime text, endTime text, deepSleep text, lowSleep text, sumSleep text, currentDataCount integer, sumDataCount integer);"]];
        
//        //SedentaryData
//        [_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SedentaryData1_1_3(id integer primary key,sedentary bool, unDisturb bool, startSedentaryTime text, endSedentaryTime text, startDisturbTime text, endDisturbTime text, timeInterval integer, stepInterval integer);"]];
    }
    
    return self;
}

//#pragma mark - ClockData
//- (BOOL)insertClockModel:(ClockModel *)model
//{
//    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO ClockData(time, isopen) VALUES ('%@', '%d');", model.time, model.isOpen];
//    
//    BOOL result = [_fmdb executeUpdate:insertSql];
//    if (result) {
//        NSLog(@"插入clockData成功");
//    }else {
//        NSLog(@"插入clockData失败");
//    }
//    return result;
//}
//
//- (NSMutableArray *)queryClockData
//{
//    NSString *queryString = [NSString stringWithFormat:@"SELECT * FROM ClockData;"];
//    
//    NSMutableArray *arrM = [NSMutableArray array];
//    FMResultSet *set = [_fmdb executeQuery:queryString];
//    
//    while ([set next]) {
//        
//        ClockModel *model = [[ClockModel alloc] init];
//        
//        model.time = [set stringForColumn:@"time"];
//        model.isOpen = [set boolForColumn:@"isopen"];
//        model.ID = [set intForColumn:@"id"];
//        
//        NSLog(@"闹钟时间 == %@，是否打开 == %d, id == %ld",model.time , model.isOpen , (long)model.ID);
//        
//        [arrM addObject:model];
//    }
//    
//    NSLog(@"查询成功");
//    return arrM;
//}
//
//- (BOOL)deleteClockData:(NSInteger)deleteSql
//{
//    BOOL result;
//    
//    if (deleteSql == 4) {
//        result =  [_fmdb executeUpdate:@"DELETE FROM ClockData"];
//    }else {
//        NSString *deleteSqlStr = [NSString stringWithFormat:@"DELETE FROM ClockData WHERE id = ?"];
//        
//        result = [_fmdb executeUpdate:deleteSqlStr,[NSNumber numberWithInteger:deleteSql]];
//    }
//    if (result) {
//        NSLog(@"删除clockData成功");
//    }else {
//        NSLog(@"删除clockData失败");
//    }
//    
//    return result;
//}
//
//- (BOOL)modifyClockModel:(ClockModel *)model withModifyID:(NSInteger)ID
//{
//    NSString *modifySqlTime = [NSString stringWithFormat:@"update ClockData set time = ? , isopen = ? where id = ?" ];
//    BOOL result = result = [_fmdb executeUpdate:modifySqlTime, model.time, [NSNumber numberWithBool:model.isOpen], [NSNumber numberWithInteger:ID]];
//    
//    if (result) {
//        NSLog(@"修改clockData成功");
//    }else {
//        NSLog(@"修改clockData失败");
//    }
//    
//    return result;
//}

#pragma mark - StepData
/**
 *  插入数据模型
 *
 *  @param model 运动数据模型
 *
 *  @return 是否成功
 */
- (BOOL)insertStepModel:(SportModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO MotionData(date, step, kCal, mileage, currentDataCount, sumDataCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.stepNumber, model.kCalNumber, model.mileageNumber, [NSNumber numberWithInteger: model.currentDataCount],[NSNumber numberWithInteger:model.sumDataCount]];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入Motion数据成功");
    }else {
        NSLog(@"插入Motion数据失败");
    }
    return result;
}

/**
 *  查找数据
 *
 *  @param date 查找的关键字
 *
 *  @return 返回所有查找的结果
 */
- (NSArray *)queryStepWithDate:(NSString *)date {
    
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM MotionData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    
    while ([set next]) {
        
        NSString *step = [set stringForColumn:@"step"];
        NSString *kCal = [set stringForColumn:@"kCal"];
        NSString *mileage = [set stringForColumn:@"mileage"];
        NSInteger currentDataCount = [set stringForColumn:@"currentDataCount"].integerValue;
        NSInteger sumDataCount = [set stringForColumn:@"sumDataCount"].integerValue;
        
        SportModel *model = [[SportModel alloc] init];
        
        model.date = date;
        model.stepNumber = step;
        model.kCalNumber = kCal;
        model.mileageNumber = mileage;
        model.currentDataCount = currentDataCount;
        model.sumDataCount = sumDataCount;
        
        NSLog(@"%@的数据：步数=%@，卡路里=%@，里程=%@",date ,step ,kCal ,mileage);
        
        [arrM addObject:model];
    }
    
    NSLog(@"Motion查询成功");
    return arrM;
}

/**
 *  修改数据内容
 *
 *  @param modifySqlDate  需要修改的日期
 *  @param modifySqlModel 需要修改的模型内容
 *
 *  @return 是否修改成功
 */
- (BOOL)modifyStepWithDate:(NSString *)date model:(SportModel *)model
{
    if (date == nil) {
        NSLog(@"传入的日期为空，不能修改");
        
        return NO;
    }
    
    NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
    
    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.stepNumber, model.kCalNumber, model.mileageNumber, date];
    
    if (modifyResult) {
        NSLog(@"Motion数据修改成功");
    }else {
        NSLog(@"Motion数据修改失败");
    }
   
    return modifyResult;
}

#pragma mark - SegmentStepData
//[_fmdb executeUpdate:[NSString stringWithFormat:@"create table if not exists SegmentStepData(id integer primary key, date text, CHCount integer, AHCount integer, stepNumber text, kCalNumber text, mileageNumber text, startTime text, timeInterval);"]];
/**
 *  插入数据模型
 *
 *  @param model 运动数据模型
 *
 *  @return 是否成功
 */
- (BOOL)insertSegmentStepModel:(SegmentedStepModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO SegmentStepData(date, stepNumber, kCalNumber, mileageNumber, startTime, timeInterval, CHCount, AHCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.stepNumber, model.kCalNumber, model.mileageNumber, model.startTime, [NSNumber numberWithInteger:model.timeInterval], [NSNumber numberWithInteger: model.CHCount],[NSNumber numberWithInteger:model.AHCount]];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入SegmentedStep数据成功");
    }else {
        NSLog(@"插入SegmentedStep数据失败");
    }
    return result;
}

/**
 *  查找数据
 *
 *  @param date 查找的关键字
 *
 *  @return 返回所有查找的结果
 */
- (NSArray *)querySegmentedStepWithDate:(NSString *)date
{
    
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM SegmentStepData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        //这里一定不能将？用需要查询的日期代替掉
        queryString = [NSString stringWithFormat:@"SELECT * FROM SegmentStepData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    
    while ([set next]) {

        NSString *stepNumber = [set stringForColumn:@"stepNumber"];
        NSString *kCalNumber = [set stringForColumn:@"kCalNumber"];
        NSString *mileageNumber = [set stringForColumn:@"mileageNumber"];
        NSString *startTime = [set stringForColumn:@"startTime"];
        NSInteger timeInterval = [set intForColumn:@"timeInterval"];
        NSInteger CHCount = [set intForColumn:@"CHCount"];
        NSInteger AHCount = [set intForColumn:@"AHCount"];
        NSString *date1 = [set stringForColumn:@"date"];
        
        SegmentedStepModel *model = [[SegmentedStepModel alloc] init];
        
        model.date = date1;
        model.stepNumber = stepNumber;
        model.kCalNumber = kCalNumber;
        model.mileageNumber = mileageNumber;
        model.startTime = startTime;
        model.timeInterval = timeInterval;
        model.CHCount = CHCount;
        model.AHCount = AHCount;
        
        [arrM addObject:model];
    }
    
    NSLog(@"SegmentMotion查询成功");
    return arrM;
}

/**
 *  修改数据内容
 *
 *  @param modifySqlDate  需要修改的日期
 *  @param modifySqlModel 需要修改的模型内容
 *
 *  @return 是否修改成功
 */
//- (BOOL)modifySegmentedStepWithDate:(NSString *)date model:(SportModel *)model
//{
//    if (date == nil) {
//        NSLog(@"传入的日期为空，不能修改");
//        
//        return NO;
//    }
//    
//    NSString *modifySql = [NSString stringWithFormat:@"update MotionData set step = ?, kCal = ?, mileage = ? where date = ?" ];
//    
//    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.stepNumber, model.kCalNumber, model.mileageNumber, date];
//    
//    if (modifyResult) {
//        NSLog(@"Motion数据修改成功");
//    }else {
//        NSLog(@"Motion数据修改失败");
//    }
//    
//    return modifyResult;
//}

#pragma mark - HeartRateData
- (BOOL)insertHeartRateModel:(HeartRateModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO HeartRateData(month, date, time, heartRate) VALUES ('%@', '%@', '%@', '%@');", model.month, model.date, model.time, model.heartRate];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入HeartRate数据成功");
    }else {
        NSLog(@"插入HeartRate数据失败");
    }
    return result;
}

- (NSArray *)queryHeartRate:(NSString *)queryStr WithType:(QueryType)type
{
    NSString *queryString;
    
    FMResultSet *set;
    switch (type) {
        case QueryTypeAll:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM HeartRateData;"];
            set = [_fmdb executeQuery:queryString];
        }
            break;
        case QueryTypeWithDay:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM HeartRateData where date = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithMonth:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM HeartRateData where month = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithLastCount:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM HeartRateData ORDER BY id DESC LIMIT %@) ORDER BY ID ASC;", queryStr];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            
        default:
            break;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *time = [set stringForColumn:@"time"];
        NSString *heartRate = [set stringForColumn:@"heartRate"];
        NSString *date = [set stringForColumn:@"date"];
        NSString *month = [set stringForColumn:@"month"];
        
        HeartRateModel *model = [[HeartRateModel alloc] init];
        
        model.time = time;
        model.heartRate = heartRate;
        model.date = date;
        model.month = month;
        
        [arrM addObject:model];
    }
    NSLog(@"heartRate查询成功");
    return arrM;
}

- (BOOL)deleteHeartRateData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"delete from HeartRateData;"];
    
    if (result) {
        NSLog(@"删除成功");
    }else {
        NSLog(@"删除失败");
    }
    
    return result;
}

#pragma mark - SleepData
- (BOOL)insertSleepModel:(SleepModel *)model
{
    
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO SleepData(date, startTime, endTime, deepSleep, lowSleep, sumSleep, currentDataCount, sumDataCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.date, model.startTime, model.endTime, model.deepSleep, model.lowSleep, model.sumSleep, [NSNumber numberWithInteger:model.currentDataCount],[NSNumber numberWithInteger:model.sumDataCount]];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入SleepData数据成功");
    }else {
        NSLog(@"插入SleepData数据失败");
    }
    return result;
}

- (NSArray *)querySleepWithDate:(NSString *)date
{
    NSString *queryString;
    
    FMResultSet *set;
    
    if (date == nil) {
        queryString = [NSString stringWithFormat:@"SELECT * FROM SleepData;"];
        
        set = [_fmdb executeQuery:queryString];
    }else {
        queryString = [NSString stringWithFormat:@"SELECT * FROM SleepData where date = ?;"];
        
        set = [_fmdb executeQuery:queryString ,date];
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *startTime = [set stringForColumn:@"startTime"];
        NSString *endTime = [set stringForColumn:@"endTime"];
        NSString *deepSleep = [set stringForColumn:@"deepSleep"];
        NSString *lowSleep = [set stringForColumn:@"lowSleep"];
        NSString *sumSleep = [set stringForColumn:@"sumSleep"];
        NSInteger currentDataCount = [set intForColumn:@"currentDataCount"];
        NSInteger sumDataCount = [set intForColumn:@"sumDataCount"];
        
        SleepModel *model = [[SleepModel alloc] init];
        
        model.startTime = startTime;
        model.endTime = endTime;
        model.deepSleep = deepSleep;
        model.lowSleep = lowSleep;
        model.sumSleep = sumSleep;
        model.currentDataCount = currentDataCount;
        model.sumDataCount = sumDataCount;
        model.date = date;
        
        NSLog(@"currentDataCount == %ld, sumDataCount == %ld, lowSleep == %@, deepSleep == %@, sumSleep == %@",currentDataCount ,sumDataCount ,lowSleep , deepSleep ,sumSleep);
        
        [arrM addObject:model];
    }
    
    NSLog(@"sleep查询成功");
    return arrM;
}

- (BOOL)modifySleepWithID:(NSInteger)ID model:(SleepModel *)model
{
    return YES;
}

- (BOOL)deleteSleepData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"delete from SleepData"];
    
    if (result) {
        NSLog(@"Sleep表删除成功");
    }else {
        NSLog(@"Sleep表删除失败");
    }
    
    return result;
}

#pragma mark - BloodPressureData
- (BOOL)insertBloodModel:(BloodModel *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO BloodData(month, day, time, highBlood, lowBlood, currentCount, sumCount, bpm) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.monthString, model.dayString, model.timeString, model.highBloodString, model.lowBloodString, model.currentCount, model.sumCount, model.bpmString];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入BloodData数据成功");
    }else {
        NSLog(@"插入BloodData数据失败");
    }
    return result;
}

- (NSArray *)queryBlood:(NSString *)queryStr WithType:(QueryType)type
{
    NSString *queryString;
    
    FMResultSet *set;
    switch (type) {
        case QueryTypeAll:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData;"];
            set = [_fmdb executeQuery:queryString];
        }
            break;
        case QueryTypeWithDay:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData where day = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithMonth:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodData where month = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithLastCount:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM BloodData ORDER BY id DESC LIMIT %@) ORDER BY ID ASC;", queryStr];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            
        default:
            break;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *month = [set stringForColumn:@"month"];
        NSString *day = [set stringForColumn:@"day"];
        NSString *time = [set stringForColumn:@"time"];
        NSString *highBlood = [set stringForColumn:@"highBlood"];
        NSString *lowBlood = [set stringForColumn:@"lowBlood"];
        NSString *currentCount = [set stringForColumn:@"currentCount"];
        NSString *sumCount = [set stringForColumn:@"sumCount"];
        NSString *bpmString = [set stringForColumn:@"bpm"];
        
        BloodModel *model = [[BloodModel alloc] init];
        
        model.monthString = month;
        model.dayString = day;
        model.timeString = time;
        model.highBloodString = highBlood;
        model.lowBloodString = lowBlood;
        model.currentCount = currentCount;
        model.sumCount = sumCount;
        model.bpmString = bpmString;
        
        [arrM addObject:model];
    }
    NSLog(@"Blood查询成功");
    return arrM;
}

- (BOOL)deleteBloodData:(NSString *)deleteSql
{
    BOOL result = [_fmdb executeUpdate:@"drop table BloodData"];
    
    if (result) {
        NSLog(@"Blood表删除成功");
    }else {
        NSLog(@"Blood表删除失败");
    }
    
    return result;
}


#pragma mark - BloodO2Data
- (BOOL)insertBloodO2Model:(BloodO2Model *)model
{
    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO BloodO2Data(month, day, time, bloodO2integer, bloodO2float, currentCount, sumCount) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@');", model.monthString, model.dayString, model.timeString, model.integerString, model.floatString, model.currentCount, model.sumCount];
    
    BOOL result = [_fmdb executeUpdate:insertSql];
    if (result) {
        NSLog(@"插入BloodO2Data数据成功");
    }else {
        NSLog(@"插入BloodO2Data数据失败");
    }
    return result;
}

- (NSArray *)queryBloodO2:(NSString *)queryStr WithType:(QueryType)type
{
    NSString *queryString;
    
    FMResultSet *set;
    switch (type) {
        case QueryTypeAll:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodO2Data;"];
            set = [_fmdb executeQuery:queryString];
        }
            break;
        case QueryTypeWithDay:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodO2Data where day = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithMonth:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM BloodO2Data where month = ?;"];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            break;
        case QueryTypeWithLastCount:
        {
            queryString = [NSString stringWithFormat:@"SELECT * FROM (SELECT * FROM BloodO2Data ORDER BY id DESC LIMIT %@) ORDER BY ID ASC;", queryStr];
            set = [_fmdb executeQuery:queryString ,queryStr];
        }
            
        default:
            break;
    }
    
    NSMutableArray *arrM = [NSMutableArray array];
    
    while ([set next]) {
        
        NSString *month = [set stringForColumn:@"month"];
        NSString *day = [set stringForColumn:@"day"];
        NSString *time = [set stringForColumn:@"time"];
        NSString *bloodO2integer = [set stringForColumn:@"bloodO2integer"];
        NSString *bloodO2float = [set stringForColumn:@"bloodO2float"];
        NSString *currentCount = [set stringForColumn:@"currentCount"];
        NSString *sumCount = [set stringForColumn:@"sumCount"];
        
        BloodO2Model *model = [[BloodO2Model alloc] init];
        
        model.monthString = month;
        model.dayString = day;
        model.timeString = time;
        model.integerString = bloodO2integer;
        model.floatString = bloodO2float;
        model.currentCount = currentCount;
        model.sumCount = sumCount;
        
        [arrM addObject:model];
    }
    NSLog(@"BloodO2查询成功");
    return arrM;
}

//#pragma mark - UserInfoData
//- (BOOL)insertUserInfoModel:(UserInfoModel *)model
//{
//    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO UserInfoData(username, gender, age, height, weight, steplength) VALUES ('%@', '%lu', '%ld', '%ld', '%ld', '%ld');", model.userName, (unsigned long)model.gender, (long)model.age, model.height, model.weight, model.stepLength];
//    
//    BOOL result = [_fmdb executeUpdate:insertSql];
//    if (result) {
//        NSLog(@"插入UserInfoData数据成功");
//    }else {
//        NSLog(@"插入UserInfoData数据失败");
//    }
//    return result;
//}
//
//- (NSArray *)queryAllUserInfo {
//    
//    NSString *queryString;
//    
//    queryString = [NSString stringWithFormat:@"SELECT * FROM UserInfoData;"];
//    
//    NSMutableArray *arrM = [NSMutableArray array];
//    FMResultSet *set = [_fmdb executeQuery:queryString];
//    
//    while ([set next]) {
//        
//        NSString *userName = [set stringForColumn:@"username"];
//        NSString *gender = [set stringForColumn:@"gender"];
//        NSInteger age = [set intForColumn:@"age"];
//        NSInteger height = [set intForColumn:@"height"];
//        NSInteger weight = [set intForColumn:@"weight"];
//        NSInteger steplength = [set intForColumn:@"steplength"];
//        NSInteger stepTarget = [set intForColumn:@"steptarget"];
//        NSInteger sleepTarget = [set intForColumn:@"sleeptarget"];
//        
//        UserInfoModel *model = [UserInfoModel userInfoModelWithUserName:userName andGender:gender andAge:age andHeight:height andWeight:weight andStepLength:steplength andStepTarget:stepTarget andSleepTarget:sleepTarget];
//        
//        NSLog(@"%@,%lu,%ld,%ld,%ld,%ld",model.userName ,(unsigned long)model.gender ,(long)model.age ,model.height ,model.weight ,model.stepLength);
//        
//        [arrM addObject:model];
//    }
//    
//    NSLog(@"UserInfoData查询成功");
//    return arrM;
//}
//
//- (BOOL)modifyUserInfoWithID:(NSInteger)ID model:(UserInfoModel *)model
//{
//    
//    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set username = ?, gender = ?, age = ?, height = ?, weight = ?, steplength = ? where id = ?" ];
//    
//    BOOL modifyResult = [_fmdb executeUpdate:modifySql, model.userName, model.gender, @(model.age), @(model.height), @(model.weight), @(model.stepLength), @(ID)];
//    
//    if (modifyResult) {
//        NSLog(@"UserInfoData数据修改成功");
//    }else {
//        NSLog(@"UserInfoData数据修改失败");
//    }
//    
//    return modifyResult;
//}
//
//- (BOOL)modifyStepTargetWithID:(NSInteger)ID model:(NSInteger)stepTarget
//{
//    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set steptarget = ? where id = ?"];
//    
//    BOOL modifyResult = [_fmdb executeUpdate:modifySql, @(stepTarget), @(ID)];
//    
//    if (modifyResult) {
//        NSLog(@"添加运动目标成功");
//    }else {
//        NSLog(@"添加运动目标失败");
//    }
//    
//    return modifyResult;
//}
//
//- (BOOL)modifySleepTargetWithID:(NSInteger)ID model:(NSInteger)sleepTarget
//{
//    NSString *modifySql = [NSString stringWithFormat:@"update UserInfoData set sleeptarget = ? where id = ?"];
//    
//    BOOL modifyResult = [_fmdb executeUpdate:modifySql, @(sleepTarget), @(ID)];
//    
//    if (modifyResult) {
//        NSLog(@"修改睡眠目标成功");
//    }else {
//        NSLog(@"修改睡眠目标失败");
//    }
//    
//    return modifyResult;
//}
//
//- (BOOL)deleteUserInfoData:(NSString *)deleteSql
//{
//    BOOL result = [_fmdb executeUpdate:@"drop table UserInfoData"];
//    
//    if (result) {
//        NSLog(@"UserInfo表删除成功");
//    }else {
//        NSLog(@"UserInfo表删除失败");
//    }
//    
//    return result;
//}

#pragma mark - CloseData
- (void)CloseDataBase
{
    [_fmdb close];
}

//#pragma mark - SedentaryData
//- (BOOL)insertSedentaryData:(SedentaryModel *)model
//{
//    NSString *insertSql = [NSString stringWithFormat:@"INSERT INTO SedentaryData1_1_3(sedentary, unDisturb, startSedentaryTime, endSedentaryTime, startDisturbTime, endDisturbTime, timeInterval, stepInterval) VALUES ('%d', '%d', '%@', '%@', '%@', '%@', '%d', '%d');", model.sedentaryAlert, model.unDisturb, model.sedentaryStartTime, model.sedentaryEndTime, model.disturbStartTime, model.disturbEndTime, model.timeInterval, model.stepInterval];
//    
//    BOOL result = [_fmdb executeUpdate:insertSql];
//    if (result) {
//        NSLog(@"插入sedentaryData成功");
//    }else {
//        NSLog(@"插入sedentaryData失败");
//    }
//    return result;
//}
//
//- (BOOL)modifySedentaryData:(SedentaryModel *)model
//{
//    NSString *modifySql = [NSString stringWithFormat:@"update SedentaryData1_1_3 set sedentary = ?, unDisturb = ?, startSedentaryTime = ?, endSedentaryTime = ?, startDisturbTime = ?, endDisturbTime = ? where id = ?"];
//    
//    BOOL modifyResult = [_fmdb executeUpdate:modifySql, @(model.sedentaryAlert), @(model.unDisturb), model.sedentaryStartTime, model.sedentaryEndTime, model.disturbStartTime, model.disturbEndTime, @(1)];
//    
//    if (modifyResult) {
//        NSLog(@"修改sedentaryData成功");
//    }else {
//        NSLog(@"修改sedentaryData失败");
//    }
//    
//    return modifyResult;
//}
//
//- (NSArray *)querySedentary
//{
//    NSString *queryString;
//    
//    FMResultSet *set;
//    
//    queryString = [NSString stringWithFormat:@"SELECT * FROM SedentaryData1_1_3;"];
//    
//    set = [_fmdb executeQuery:queryString];
//    
//    NSMutableArray *arrM = [NSMutableArray array];
//    
//    while ([set next]) {
//        BOOL sedentary = [set boolForColumn:@"sedentary"];
//        BOOL unDisturb = [set boolForColumn:@"unDisturb"];
//        NSString *startSedentaryTime = [set stringForColumn:@"startSedentaryTime"];
//        NSString *endSedentaryTime = [set stringForColumn:@"endSedentaryTime"];
//        NSString *startDisturbTime = [set stringForColumn:@"startDisturbTime"];
//        NSString *endDisturbTime = [set stringForColumn:@"endDisturbTime"];
//        int timeInterval = [set intForColumn:@"timeInterval"];
//        int stepInterval = [set intForColumn:@"stepInterval"];
//        
//        SedentaryModel *model = [[SedentaryModel alloc] init];
//        
//        model.sedentaryAlert = sedentary;
//        model.unDisturb = unDisturb;
//        model.sedentaryStartTime = startSedentaryTime;
//        model.sedentaryEndTime = endSedentaryTime;
//        model.disturbStartTime = startDisturbTime;
//        model.disturbEndTime = endDisturbTime;
//        model.timeInterval = timeInterval;
//        model.stepInterval = stepInterval;
//        
//        [arrM addObject:model];
//    }
//    NSLog(@"sedentary查询成功");
//    return arrM;
//}
//
//- (BOOL)deleteSendentaryData:(SedentaryModel *)model
//{
//    BOOL result = [_fmdb executeUpdate:@"drop table SedentaryData"];
//    
//    if (result) {
//        NSLog(@"SedentaryData表删除成功");
//    }else {
//        NSLog(@"SedentaryData表删除失败");
//    }
//    
//    return result;
//}

@end
