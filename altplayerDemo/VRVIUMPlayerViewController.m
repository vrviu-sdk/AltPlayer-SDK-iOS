

#import "VRVIUMPlayerViewController.h"
#import "VRVIUCommon.h"
#import "VRVIUInputURLViewController.h"
#import "VRVIUPlayerHistory.h"
#import "VRVIUVideoPlayerViewController.h"
#import "VRVIUMPlayerLocalFileViewController.h"
#
#import <MobileCoreServices/MobileCoreServices.h>

@interface VRVIUMPlayerViewController () <UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property(nonatomic,strong) IBOutlet UITableView *tableView;
@property(nonatomic,strong) NSArray *tableViewCellTitles;
@property(nonatomic,strong) NSArray *historyList;

@end

@implementation VRVIUMPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.title = @"VRVIU-Carbon";
    /*
    self.tableViewCellTitles = @[
                                 @"Local Folder",
                                 @"Movie Picker",
                                 @"Input URL",
                                 @"Scan QRCode",
                                 @"Online Samples",
                                 ];
     
     */
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Enable_Authencation"];
    [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"Enable_FE"];
    [[NSUserDefaults standardUserDefaults] setInteger:13 forKey:@"VRVIU_FILTER_VERSION"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSString *strDemoVer = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *strVer = [NSString stringWithFormat:@"altplayerDemo:v%@", strDemoVer];
    self.title = strVer;
    self.tableViewCellTitles = @[
                                 @"Photo Picker",
                                 @"Input URL",
                                 @"Player Setting"
                                 ];
    
    NSURL *documentsUrl = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
    
    NSError *error = nil;
    
    [documentsUrl setResourceValue:[NSNumber numberWithBool:YES]
                            forKey:NSURLIsExcludedFromBackupKey
                             error:&error];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.historyList = [[VRVIUPlayerHistory instance] list];

    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"";
        case 1:
            return @"Open from";
            
        case 2:
            return @"History Record";
            
        default:
            return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return 1;
        case 1:
            if (IOS_NEWER_OR_EQUAL_TO_7) {
                return self.tableViewCellTitles.count;
            } else {
                return self.tableViewCellTitles.count - 1;
            }
            
        case 2:
            return self.historyList.count;
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"abc"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"abc"];
        cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    }
    
    switch (indexPath.section) {
        case 0:
            break;
        case 1:
            cell.textLabel.text = self.tableViewCellTitles[indexPath.row];
            break;
            
        case 2:
            cell.textLabel.text = [self.historyList[indexPath.row] title];
            break;
            
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 1: {
            switch (indexPath.row) {
                case 0: {
                    
                    [self startMediaBrowserFromViewController: self
                                                usingDelegate: self];
                   
                } break;

                case 1:
                    
                    
                    [self.navigationController pushViewController:[[VRVIUInputURLViewController alloc] init] animated:YES];
                    break;

                case 2:
                    // player settin

                    break;

                case 3:
                    
                    break;

                case 4:
                    
                    break;

                default:
                    break;
            }
        } break;
            
        case 2: {
            VRVIUPlayerHistoryItem *historyItem = self.historyList[indexPath.row];
            
            [VRVIUVideoPlayerViewController presentFromViewController:self withTitle:historyItem.title URL:historyItem.url completion:^{
                [self.navigationController popViewControllerAnimated:NO];
            }];
        } break;
            
        default:
            break;
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 1);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        return UITableViewCellEditingStyleDelete;
    }

    return UITableViewCellEditingStyleNone;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && editingStyle == UITableViewCellEditingStyleDelete) {
        [[VRVIUPlayerHistory instance] removeAtIndex:indexPath.row];
        self.historyList = [[VRVIUPlayerHistory instance] list];

        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    NSURL *movieUrl;

    // Handle a movied picked from a photo album
    if (CFStringCompare ((CFStringRef) mediaType, kUTTypeMovie, 0)
        == kCFCompareEqualTo) {

        NSString *moviePath = [[info objectForKey:
                                UIImagePickerControllerMediaURL] path];
        movieUrl = [NSURL URLWithString:moviePath];
    }

    [self dismissViewControllerAnimated:YES completion:^(void){
        [self.navigationController pushViewController:[[VRVIUVideoPlayerViewController alloc]   initWithURL:movieUrl] animated:YES];
    }];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark misc

- (BOOL) startMediaBrowserFromViewController: (UIViewController*) controller
                               usingDelegate: (id <UIImagePickerControllerDelegate,
                                               UINavigationControllerDelegate>) delegate {

    if (([UIImagePickerController isSourceTypeAvailable:
          UIImagePickerControllerSourceTypeSavedPhotosAlbum] == NO)
        || (delegate == nil)
        || (controller == nil))
        return NO;

    UIImagePickerController *mediaUI = [[UIImagePickerController alloc] init];
    mediaUI.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;

    // Displays saved pictures and movies, if both are available, from the
    // Camera Roll album.
    mediaUI.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];

    // Hides the controls for moving & scaling pictures, or for
    // trimming movies. To instead show the controls, use YES.
    mediaUI.allowsEditing = NO;

    mediaUI.delegate = delegate;

    [controller presentViewController:mediaUI animated:YES completion:nil];
    return YES;
}

@end
