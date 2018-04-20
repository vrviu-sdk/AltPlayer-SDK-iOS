

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface Barcode : NSObject

+ (Barcode * )processMetadataObject:(AVMetadataMachineReadableCodeObject*) code;
- (NSString *) getBarcodeType;
- (NSString *) getBarcodeData;
- (void) printBarcodeData;
@end
