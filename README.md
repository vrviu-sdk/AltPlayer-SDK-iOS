# AltPlayer-SDK-iOS

[![](https://img.shields.io/badge/Powered%20by-vrviu.com-brightgreen.svg)](https://vrviu.com)

## 版本
V1.3

## 功能说明
支持点播以及直播功能，其中直播是网络主播实时推送的视频流，用户能够及时看到主播的画面。点播是播放云端或者本地的文件。

## 产品特点
* **高效的视频编码算法**：针对网络主播视频特点设计出独特的[**FE编码算法**](https://www.vrviu.com/technology.html)。经测试， FE编码算法在同等清晰度的前提下能够节省40%的传输带宽。

* **播放器格式支持**：可以支持常见视频格式播放，也可以播放使用威尔云编码后的视频。

* **直播视频秒开**：通过优化播放器缓冲策略、网络加载等，该SDK可以实现秒开。

* **多协议支持**：支持HLS/RTMP/HTTP-FLV/HTTP-MP4等常见标准协议，以及本地文件的播放。

* **接口简单全面**：实现播放接口简单，可快速实现播放。提供播放器状态监听接口以及错误信息通知接口、日志接口、算法参数配置接口等。

* **解码性能强大**：支持H264、H265、AAC，支持4K视频硬件解码以及2K以下视频软件解码。

* **多平台**：支持ARMV7、ARM64平台。

## 开发环境
Xcode

## 快速体验威尔云 [FE算法](https://www.vrviu.com/technology.html) 
* 下载最新的github代码后，编译安装。

* 推送一路RTMP流至 rtmp://rs1-pu.vrviu.com:38667/live/vrviu_altsdk，建议规格：分辨率720P，15FPS, H.264 1.2Mbps 或 H.265 1Mbps。

* 在安装好的APP的Input URL中填写 http://rs1-pl.vrviu.com/live/vrviu_altsdk.flv?auth_key=1540277586-0-0-becf2e8ef7e862620b469c573e420a25
，即可播放威尔云FE算法视频。720P码率仅需 H.264 650Kbps 或 H.265 600Kbps。

## 导入工程
### 1. 开发准备
下载最新的Demo和SDK。
Demo工程目录如下，打开xcodeproj文件即可

![](https://github.com/vrviu-sdk/VRVIU-AltPlayer-Demo-iOS/blob/master/image/libpath.png)

### 2. 导入工程
##### 2.1 导入SDK包
将vrviu-sdk包放到工程目录下，如图

![](https://github.com/vrviu-sdk/VRVIU-AltPlayer-Demo-iOS/blob/master/image/libproject.png)


依赖库中，确保添加

![](https://github.com/vrviu-sdk/VRVIU-AltPlayer-Demo-iOS/blob/master/image/linklib.png)

##### 2.2 配置工程权限
需要访问相册，请配置好对应权限：
 
![](https://github.com/vrviu-sdk/VRVIU-AltPlayer-Demo-iOS/blob/master/image/setting.png)

### 3. 引用SDK
##### 3.1 添加控件
在xib或者storyboard中添加控件：显示视频的view，控制播放的按钮等。

##### 3.2调用接口
在视频播放的viewController中的viewDidLoad中，初始化player：

```objc
VRVIUOptions *options = [VRVIUOptions optionsByDefault];
self.player=[[VRVIUMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
[options setPlayerOptionValue:@"a2fe8f5e4767e6c3dca8beb9b410f17a" forKey:@"access_key"]; 
[optins setPlayerOptionValue:@"dcb0af5f194f410796452a1644132f03" forKey:@"access_key_id"];
[options setPlayerOptionValue:@"vrviu_altsdk" forKey:@"app_id"];
[options setPlayerOptionValue:@"altsdk_alpha" forKey:@"biz_id"];
[options setPlayerOptionValue:@"vrviu_sdk_base_ios_1_0" forKey:@"sdk_version"];
self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
self.player.view.frame = self.view.bounds;
self.player.scalingMode = VRVIUMPMovieScalingModeAspectFit;
self.player.shouldAutoplay = YES;
self.player.view.backgroundColor = [UIColor blackColor];
self.view.autoresizesSubviews = YES;
[self.view addSubview:self.player.view];
```

##### 3.3 设置监听事件

```objc
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self installMovieNotificationObservers];
    [self.player prepareToPlay];
}

-(void)installMovieNotificationObservers
{
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:VRVIUMPMoviePlayerLoadStateDidChangeNotification object:_player];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:VRVIUMPMoviePlayerPlaybackDidFinishNotification object:_player];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaIsPreparedToPlayDidChange:) name:VRVIUMPMediaPlaybackIsPreparedToPlayDidChangeNotification
object:_player];

[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackStateDidChange:) name:VRVIUMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}
```

##### 3.4 结束播放

```objc
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}
```

##### 3.5 暂停播放

```objc
- (IBAction)onClickPause:(id)sender
{
    [self.player pause];
    [self.mediaControl refreshMediaControl];
}
```

## 账号鉴权参数表
|参数|说明|是否必填|类型|
|:---|:---|:---|:---|
|AppId|分配给用户的ID，可通过 www.vrviu.com 填写表单或者联系客服申请|必填|NSString|
|AccessKeyId|分配给用户的ID，可通过 www.vrviu.com 填写表单或者联系客服申请|必填|NSString|
|BizId|分配给用户的ID，可通过 www.vrviu.com 填写表单或者联系客服申请|必填|NSString|
|AccessKey|分配给用户的ID，可通过 www.vrviu.com 填写表单或者联系客服申请|必填|NSString|

## 商务合作
电话：0755-86960615

邮箱：business@vrviu.com
