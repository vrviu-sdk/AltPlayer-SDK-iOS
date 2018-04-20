

#import <UIKit/UIKit.h>

@protocol VRVIUMediaPlayback;

@interface VRVIUMediaControl : UIControl

- (void)showNoFade;
- (void)showAndFade;
- (void)hide;
- (void)refreshMediaControl;

- (void)beginDragMediaSlider;
- (void)endDragMediaSlider;
- (void)continueDragMediaSlider;

@property(nonatomic,weak) id<VRVIUMediaPlayback> delegatePlayer;

@property(nonatomic,strong) IBOutlet UIView *overlayPanel;
@property(nonatomic,strong) IBOutlet UIView *topPanel;
@property(nonatomic,strong) IBOutlet UIView *bottomPanel;

@property(nonatomic,strong) IBOutlet UIButton *playButton;
@property(nonatomic,strong) IBOutlet UIButton *pauseButton;

@property(nonatomic,strong) IBOutlet UILabel *currentTimeLabel;
@property(nonatomic,strong) IBOutlet UILabel *totalDurationLabel;
@property(nonatomic,strong) IBOutlet UISlider *mediaProgressSlider;


@end
