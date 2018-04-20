
#import <UIKit/UIKit.h>
#import <VRVIUPlayerFramework/VRVIUPlayerFramework.h>
@class VRVIUMediaControl;

@interface VRVIUVideoPlayerViewController : UIViewController

@property(atomic,strong) NSURL *url;
@property(atomic, retain) id<VRVIUMediaPlayback> player;

- (id)initWithURL:(NSURL *)url;

+ (void)presentFromViewController:(UIViewController *)viewController withTitle:(NSString *)title URL:(NSURL *)url completion:(void(^)())completion;

- (IBAction)onClickMediaControl:(id)sender;
- (IBAction)onClickOverlay:(id)sender;
- (IBAction)onClickDone:(id)sender;
- (IBAction)onClickPlay:(id)sender;
- (IBAction)onClickPause:(id)sender;

- (IBAction)didSliderTouchDown;
- (IBAction)didSliderTouchCancel;
- (IBAction)didSliderTouchUpOutside;
- (IBAction)didSliderTouchUpInside;
- (IBAction)didSliderValueChanged;

@property(nonatomic,strong) IBOutlet VRVIUMediaControl *mediaControl;

@end
