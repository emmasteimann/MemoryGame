//
//  ImageDownloader.m
//
//

#import "ImageDownloader.h"

@implementation ImageDownloader
- (void) loadImageFromURLString: (NSString*)url callback:(void (^)(UIImage *image, NSString *imageUrl))callback {
  dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  dispatch_async(queue, ^{
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url]];
    NSURLSessionDataTask *dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
      
      if (!error){
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        
        if (httpResp.statusCode == 200){
          UIImage *image = [[UIImage alloc] initWithData:data];
          dispatch_async(dispatch_get_main_queue(), ^{
            callback(image, url);
          });
        }
      } else{
        DLog(@"%@", error.localizedDescription);
      }
      
    }];
    
    [dataTask resume];
  });
}
@end
