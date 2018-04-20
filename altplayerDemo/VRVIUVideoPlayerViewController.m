
#import "VRVIUVideoPlayerViewController.h"
#import "VRVIUMediaControl.h"
#import "VRVIUCommon.h"
#import "VRVIUPlayerHistory.h"

@implementation VRVIUVideoPlayerViewController

- (void)dealloc
{
}

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void (^)())completion {
    VRVIUPlayerHistoryItem *historyItem = [[VRVIUPlayerHistoryItem alloc] init];
    
    historyItem.title = title;
    historyItem.url = url;
    [[VRVIUPlayerHistory instance] add:historyItem];
    
    [viewController presentViewController:[[VRVIUVideoPlayerViewController alloc] initWithURL:url] animated:YES completion:completion];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [self initWithNibName:@"VRVIUVideoPlayerViewController" bundle:nil];
    if (self) {
        self.url = url;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#define EXPECTED_VRVIUPLAYER_VERSION (1 << 16) & 0xFF) | 
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.

#ifdef DEBUG
    [VRVIUMoviePlayerController setLogReport:YES];
    [VRVIUMoviePlayerController setLogLevel:k_VRVIU_LOG_DEBUG];
#else
    [VRVIUMoviePlayerController setLogReport:NO];
    [VRVIUMoviePlayerController setLogLevel:k_VRVIU_LOG_INFO];
#endif

    [VRVIUMoviePlayerController checkIfFFmpegVersionMatch:YES];
    

    VRVIUOptions *options = [VRVIUOptions optionsByDefault];
    [options setPlayerOptionValue:@"vrviu_test_access_key@1234" forKey:@"access_key"];
    [options setPlayerOptionValue:@"vrviu_test_access_key_id" forKey:@"access_key_id"];
    [options setPlayerOptionValue:@"vrviu_test_user" forKey:@"app_id"];
    [options setPlayerOptionValue:@"vrviu_test_user" forKey:@"biz_id"];
    [options setPlayerOptionValue:@"vrviu_sdk_base_ios_1_0" forKey:@"sdk_version"];
    

    self.player = [[VRVIUMoviePlayerController alloc] initWithContentURL:self.url withOptions:options];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.player.view.frame = self.view.bounds;
    self.player.scalingMode = VRVIUMPMovieScalingModeAspectFit;
    self.player.shouldAutoplay = YES;
    self.player.view.backgroundColor = [UIColor blackColor];

    self.view.autoresizesSubviews = YES;
    [self.view addSubview:self.player.view];
    [self.view addSubview:self.mediaControl];

    self.mediaControl.delegatePlayer = self.player;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self installMovieNotificationObservers];

    [self.player prepareToPlay];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self.player shutdown];
    [self removeMovieNotificationObservers];
}

//强制转屏
- (void)interfaceOrientation:(UIInterfaceOrientation)orientation
{
    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
        SEL selector  = NSSelectorFromString(@"setOrientation:");
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
        [invocation setSelector:selector];
        [invocation setTarget:[UIDevice currentDevice]];
        int val = orientation;
        // 从2开始是因为0 1 两个参数已经被selector和target占用
        [invocation setArgument:&val atIndex:2];
        [invocation invoke];
    }
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;//UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;//UIInterfaceOrientationMaskLandscape;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark IBAction

- (IBAction)onClickMediaControl:(id)sender
{
    [self.mediaControl showAndFade];
}

- (IBAction)onClickOverlay:(id)sender
{
    [self.mediaControl hide];
}

- (IBAction)onClickDone:(id)sender
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onClickHUD:(UIBarButtonItem *)sender
{
    if ([self.player isKindOfClass:[VRVIUMoviePlayerController class]]) {
        VRVIUMoviePlayerController *player = self.player;
        player.shouldShowHudView = !player.shouldShowHudView;
        
        sender.title = (player.shouldShowHudView ? @"Info On" : @"Info Off");
    }
}

- (IBAction)onClickPlay:(id)sender
{
    [self.player play];
    [self.mediaControl refreshMediaControl];
}

- (IBAction)onClickPause:(id)sender
{
    [self.player pause];
    [self.mediaControl refreshMediaControl];
}

- (IBAction)didSliderTouchDown
{
    [self.mediaControl beginDragMediaSlider];
}

- (IBAction)didSliderTouchCancel
{
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderTouchUpOutside
{
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderTouchUpInside
{
    self.player.currentPlaybackTime = self.mediaControl.mediaProgressSlider.value;
    [self.mediaControl endDragMediaSlider];
}

- (IBAction)didSliderValueChanged
{
    [self.mediaControl continueDragMediaSlider];
}

- (void)loadStateDidChange:(NSNotification*)notification
{
    //    MPMovieLoadStateUnknown        = 0,
    //    MPMovieLoadStatePlayable       = 1 << 0,
    //    MPMovieLoadStatePlaythroughOK  = 1 << 1, // Playback will be automatically started in this state when shouldAutoplay is YES
    //    MPMovieLoadStateStalled        = 1 << 2, // Playback will be automatically paused in this state, if started

    VRVIUMPMovieLoadState loadState = _player.loadState;

    if ((loadState & VRVIUMPMovieLoadStatePlaythroughOK) != 0) {
        NSLog(@"loadStateDidChange: VRVIUMPMovieLoadStatePlaythroughOK: %d\n", (int)loadState);
    } else if ((loadState & VRVIUMPMovieLoadStateStalled) != 0) {
        NSLog(@"loadStateDidChange: VRVIUMPMovieLoadStateStalled: %d\n", (int)loadState);
    } else {
        NSLog(@"loadStateDidChange: ???: %d\n", (int)loadState);
    }
}

- (void)moviePlayBackDidFinish:(NSNotification*)notification
{
    //    MPMovieFinishReasonPlaybackEnded,
    //    MPMovieFinishReasonPlaybackError,
    //    MPMovieFinishReasonUserExited
    int reason = [[[notification userInfo] valueForKey:VRVIUMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];

    switch (reason)
    {
        case VRVIUMPMovieFinishReasonPlaybackEnded:
            NSLog(@"playbackStateDidChange: VRVIUMPMovieFinishReasonPlaybackEnded: %d\n", reason);
            break;

        case VRVIUMPMovieFinishReasonUserExited:
            NSLog(@"playbackStateDidChange: VRVIUMPMovieFinishReasonUserExited: %d\n", reason);
            break;

        case VRVIUMPMovieFinishReasonPlaybackError:
            NSLog(@"playbackStateDidChange: VRVIUMPMovieFinishReasonPlaybackError: %d\n", reason);
            break;

        default:
            NSLog(@"playbackPlayBackDidFinish: ???: %d\n", reason);
            break;
    }
}

- (void)mediaIsPreparedToPlayDidChange:(NSNotification*)notification
{
    NSLog(@"mediaIsPreparedToPlayDidChange\n");
}

- (void)moviePlayBackStateDidChange:(NSNotification*)notification
{
    //    MPMoviePlaybackStateStopped,
    //    MPMoviePlaybackStatePlaying,
    //    MPMoviePlaybackStatePaused,
    //    MPMoviePlaybackStateInterrupted,
    //    MPMoviePlaybackStateSeekingForward,
    //    MPMoviePlaybackStateSeekingBackward

    switch (_player.playbackState)
    {
        case VRVIUMPMoviePlaybackStateStopped: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: stoped", (int)_player.playbackState);
            break;
        }
        case VRVIUMPMoviePlaybackStatePlaying: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: playing", (int)_player.playbackState);
            break;
        }
        case VRVIUMPMoviePlaybackStatePaused: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: paused", (int)_player.playbackState);
            break;
        }
        case VRVIUMPMoviePlaybackStateInterrupted: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: interrupted", (int)_player.playbackState);
            break;
        }
        case VRVIUMPMoviePlaybackStateSeekingForward:
        case VRVIUMPMoviePlaybackStateSeekingBackward: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: seeking", (int)_player.playbackState);
            break;
        }
        default: {
            NSLog(@"VRVIUMPMoviePlayBackStateDidChange %d: unknown", (int)_player.playbackState);
            break;
        }
    }
}

#pragma mark Install Movie Notifications

/* Register observers for the various movie object notifications. */
-(void)installMovieNotificationObservers
{
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(loadStateDidChange:)
                                                 name:VRVIUMPMoviePlayerLoadStateDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackDidFinish:)
                                                 name:VRVIUMPMoviePlayerPlaybackDidFinishNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(mediaIsPreparedToPlayDidChange:)
                                                 name:VRVIUMPMediaPlaybackIsPreparedToPlayDidChangeNotification
                                               object:_player];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(moviePlayBackStateDidChange:)
                                                 name:VRVIUMPMoviePlayerPlaybackStateDidChangeNotification
                                               object:_player];
}

#pragma mark Remove Movie Notification Handlers

/* Remove the movie notification observers from the movie object. */
-(void)removeMovieNotificationObservers
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VRVIUMPMoviePlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VRVIUMPMoviePlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VRVIUMPMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:VRVIUMPMoviePlayerPlaybackStateDidChangeNotification object:_player];
}

@end
