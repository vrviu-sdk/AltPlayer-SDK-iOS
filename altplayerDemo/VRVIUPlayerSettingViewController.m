//
//  VRVIUPlayerSettingViewController.m
//  
//
//  Created by Felix on 2018/3/8.
//  Copyright © 2018年 vrviu. All rights reserved.
//

#import "VRVIUPlayerSettingViewController.h"

@interface VRVIUPlayerSettingViewController ()<UIPickerViewDataSource,UIPickerViewDelegate>
{
    NSArray *dataarray;
}

@end

@implementation VRVIUPlayerSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //数据源数组
    dataarray = @[@"Filter-V00",@"Filter-V10",@"Filter-V12",@"Filter-V13"];
    _filterVerPickerView.dataSource = self;
    _filterVerPickerView.delegate = self;
    // Do any additional setup after loading the view from its nib.
}



//4⃣️实现代理
#pragma mark -----数据源UIPickerViewDataSource代理的方法-
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return dataarray.count;
}
#pragma mark -----数据源UIPickerViewDelegate代理的方法
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *selString = [NSString stringWithFormat:@"row%ld component%ld",row+1,component+1];
    if ([selString isEqualToString:@"Filter-V00"]) {
        [defaults setInteger:00 forKey:@"VRVIU_FILTER_VERSION"];
    }
    else if ([selString isEqualToString:@"Filter-V10"]) {
        [defaults setInteger:10 forKey:@"VRVIU_FILTER_VERSION"];
    }
    else if ([selString isEqualToString:@"Filter-V12"]) {
        [defaults setInteger:12 forKey:@"VRVIU_FILTER_VERSION"];
    }
    else if ([selString isEqualToString:@"Filter-V13"]) {
        [defaults setInteger:13 forKey:@"VRVIU_FILTER_VERSION"];
    }
    [defaults synchronize];
    /*
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"选中" message:alertString preferredStyle:UIAlertControllerStyleAlert];
    
    //    添加按钮
    UIAlertAction *alertButton  = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    //按钮添加到弹出框
    [alertController addAction:alertButton];
    
    //显示出来
    [self presentViewController:alertController animated:YES completion:^{
        
    }];*/
    
}
//返回指定行的标题
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (component == 0) {
        return dataarray[row];
    }
}

- (IBAction)onClickAuthSwitchBtn:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (isButtonOn) {
        [defaults setInteger:1 forKey:@"Enable_Authencation"];
    }else {
        [defaults setInteger:0 forKey:@"Enable_Authencation"];
    }
    [defaults synchronize];
}
- (IBAction)onClickFESwitchBtn:(id)sender {
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (isButtonOn) {
        [defaults setInteger:1 forKey:@"Enable_FE"];
    }else {
        [defaults setInteger:0 forKey:@"Enable_FE"];
    }
    [defaults synchronize];
}
- (IBAction)onClickFilterSwitchBtn:(id)sender {
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
