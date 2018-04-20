//
//  VRVIUPlayerSettingViewController.h
//  VRVIUMediaDemo
//
//  Created by Felix on 2018/3/8.
//  Copyright © 2018年 vrviu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VRVIUPlayerSettingViewController : UIViewController
@property (weak, nonatomic) IBOutlet UISwitch *_authSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *_feSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *_filterSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *filterVerPickerView;

@end
