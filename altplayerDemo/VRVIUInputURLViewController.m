

#import "VRVIUInputURLViewController.h"
#import "VRVIUVideoPlayerViewController.h"

@interface VRVIUInputURLViewController () <UITextViewDelegate>

@property(nonatomic,strong) IBOutlet UITextView *textView;

@end

@implementation VRVIUInputURLViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"Input URL";
        
        [self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithTitle:@"Play" style:UIBarButtonItemStyleDone target:self action:@selector(onClickPlayButton)]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *strurl = @"http://120.77.204.104:38666/20000_0.flv";//@"http://120.77.204.104:31665/20000.flv";//@"http://10.86.0.107/normal.mp4";
    self.textView.text = strurl;//
}

- (void)onClickPlayButton {
    NSURL *url = [NSURL URLWithString:self.textView.text];
    NSString *scheme = [[url scheme] lowercaseString];
    
    if ([scheme isEqualToString:@"http"]
        || [scheme isEqualToString:@"https"]
        || [scheme isEqualToString:@"rtmp"]) {
        [VRVIUVideoPlayerViewController presentFromViewController:self withTitle:[NSString stringWithFormat:@"URL: %@", url] URL:url completion:^{
//            [self.navigationController popViewControllerAnimated:NO];
        }];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    [self onClickPlayButton];
}

@end
