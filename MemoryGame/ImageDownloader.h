//
//  ImageDownloader.h
//

@import UIKit;

@interface ImageDownloader : NSObject
@property (nonatomic, copy) void (^completionHandler)(void);
- (void) loadImageFromURLString: (NSString*)url callback:(void (^)(UIImage *image, NSString *imageUrl))callback;
@end
