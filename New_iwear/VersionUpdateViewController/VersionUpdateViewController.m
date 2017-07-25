//
//  VersionUpdateViewController.m
//  New_iwear
//
//  Created by JustFei on 2017/5/25.
//  Copyright © 2017年 manridy. All rights reserved.
//

#import "VersionUpdateViewController.h"
#import "VersionUpdateTableViewCell.h"
#import "UpdateViewController.h"
//#import "AFNetworking.h"

static NSString *const VersionUpdateTableViewCellID = @"VersionUpdateTableViewCell";

@interface VersionUpdateViewController () < UITableViewDelegate, UITableViewDataSource, NSXMLParserDelegate >

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArr;
@property (nonatomic, strong) UIAlertController *updateAc;
@property (nonatomic, strong) NSString *filePath;
@property (nonatomic, strong) MDToast *loadingToast;

@end

@implementation VersionUpdateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = NSLocalizedString(@"checkUpdate", nil);
    MDButton *leftButton = [[MDButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24) type:MDButtonTypeFlat rippleColor:nil];
    [leftButton setImageNormal:[UIImage imageNamed:@"ic_back"]];
    [leftButton addTarget:self action:@selector(backViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftButton];
    
    self.tableView.backgroundColor = CLEAR_COLOR;
    self.view.backgroundColor = SETTING_BACKGROUND_COLOR;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    VersionUpdateTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:VersionUpdateTableViewCellID];
    
    cell.model = self.dataArr[indexPath.row];
    
    cell.updateActionBlock = ^{
        
        if ([BleManager shareInstance].connectState == kBLEstateDisConnected) {
            [((AppDelegate *)[UIApplication sharedApplication].delegate) showTheStateBar];
        }else {
            self.loadingToast = [[MDToast alloc] initWithText:NSLocalizedString(@"checkUpdating", nil) duration: 10000];
            [self.loadingToast show];
            
            NSURL *url = [NSURL URLWithString:@"http://39.108.92.15:12345/version.xml"];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:1 timeoutInterval:10.0];
            [NSURLConnection sendAsynchronousRequest:request queue:[[NSOperationQueue alloc]init] completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
                NSLog(@"connectionError == %@", connectionError);
                if (!connectionError) {
                    //创建xml解析器
                    NSXMLParser *parser = [[NSXMLParser alloc]initWithData:data];
                    //设置代理
                    parser.delegate = self;
                    //开始解析
                    [parser parse];
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingToast setText:NSLocalizedString(@"netError", nil)];
                    });
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self.loadingToast dismiss];
                    });
                }
            }];
        }
    };
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 48;
}

#pragma mark - NSXMLParserDelegate
- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"1.开始文档");
}

//每发现一个开始节点就调用

/**
 *  每发现一个节点就调用
 *  *  @param parser        解析器
 *  @param elementName   节点名字
 *  @param attributeDict 属性字典
 */
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName attributes:(NSDictionary<NSString *, NSString *> *)attributeDict
{
    NSLog(@"2.发现节点：%@",elementName);
    if ([elementName isEqualToString:@"product"])
    {
        //获取 id 号
        NSString *idcount = attributeDict[@"id"];
        if ([idcount isEqualToString:@"0001"]) {
            self.filePath = [@"http://39.108.92.15:12345" stringByAppendingString:[NSString stringWithFormat:@"/0001/%@", attributeDict[@"file"]]];
            NSString *verInServer = attributeDict[@"least"];
            if ([[NSUserDefaults standardUserDefaults] objectForKey:HARDWARE_VERSION]) {
                NSString *hardVer = [[NSUserDefaults standardUserDefaults] objectForKey:HARDWARE_VERSION];
                if ([verInServer compare:hardVer options:NSNumericSearch] == NSOrderedDescending) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingToast dismiss];
                        //提示是否更新
                        [self presentViewController:self.updateAc animated:YES completion:nil];
                    });
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self.loadingToast setText:NSLocalizedString(@"noUpdate", nil)];
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                            [self.loadingToast dismiss];
                        });
                    });
                }
            }
        }
    }
    
//    [self.elementNameString setString:@""];
}

//发现节点内容
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    NSLog(@"3.发现节点内容：%@",string);
    //把发现的内容进行拼接
//    [self.elementNameString appendString:string];
}

//发现结束节点
- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(nullable NSString *)namespaceURI qualifiedName:(nullable NSString *)qName
{
    NSLog(@"3.发现结束节点 %@",elementName);
    //    NSLog(@"拼接的内容%@",self.elementNameString);
    
    if ([elementName isEqualToString:@"name"])
    {
//        self.video.name = self.elementNameString;
    }else if ([elementName isEqualToString:@"teacher"])
    {
//        self.video.teacher = self.elementNameString;
    }
}

//解析完毕调用
- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    NSLog(@"解析完毕---------");
    
//    NSLog(@"%@",self.video);
}

#pragma mark - Action
- (void)backViewController
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - lazy
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:NSClassFromString(VersionUpdateTableViewCellID) forCellReuseIdentifier:VersionUpdateTableViewCellID];
        _tableView.allowsSelection = NO;
        _tableView.scrollEnabled = NO;
        _tableView.tableFooterView = [[UIView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_top);
            make.left.equalTo(self.view.mas_left);
            make.right.equalTo(self.view.mas_right);
            make.bottom.equalTo(self.view.mas_bottom);
        }];
    }
    
    return _tableView;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        VersionModel *model0 = [VersionModel modelWithTitle:NSLocalizedString(@"softwareVersion", nil) andVersion:app_Version];
        model0.versionType = VersionTypeSoftware;
        NSString *hardware_Version = [[NSUserDefaults standardUserDefaults] objectForKey:HARDWARE_VERSION];
        VersionModel *model1 = [VersionModel modelWithTitle:NSLocalizedString(@"hardwareVersion", nil) andVersion:hardware_Version == nil ? @"" : hardware_Version];
        model1.versionType = VersionTypeHardware;
        
        _dataArr = @[model0, model1];
    }
    
    return _dataArr;
}

- (UIAlertController *)updateAc
{
    if (!_updateAc) {
        _updateAc = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"tips", nil) message:NSLocalizedString(@"sureUpdate", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *cancelAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"cancel", nil) style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *okAc = [UIAlertAction actionWithTitle:NSLocalizedString(@"sure", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UpdateViewController *vc = [[UpdateViewController alloc] init];
            vc.filePa = self.filePath;
            [self presentViewController:vc animated:YES completion:nil];
        }];
        [_updateAc addAction:cancelAc];
        [_updateAc addAction:okAc];
    }
    
    return _updateAc;
}

@end
