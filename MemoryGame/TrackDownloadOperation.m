//
//  TrackDownloadOperation.m
//

#import "TrackDownloadOperation.h"
#import "Constants.h"

@interface TrackDownloadOperation()
@end

@implementation TrackDownloadOperation {
  NSURLSessionDataTask *_dataTask;
}
-(id)init {
  if (self = [super init])  {
    _artistId = @"";
  }
  return self;
}
- (void)main {
    NSString *urlString = [NSString stringWithFormat:@"http://api.soundcloud.com/users/%@/tracks?client_id=%@", _artistId, clientID];
    NSURL *url = [NSURL URLWithString:urlString];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    _dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
      
      if (!error){
        NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
        
        if (httpResp.statusCode == 200){
          NSError *jsonErr;
          
          NSArray *dataArray =
          [NSJSONSerialization JSONObjectWithData:data
                                          options:NSJSONReadingAllowFragments
                                            error:&jsonErr];
          
          if (!jsonErr){
            self.result = dataArray;
            [self completeOperation];
            return;
          }
          else{
            DLog(@"%@", jsonErr.localizedDescription);
          }
        }
      } else{
        DLog(@"%@", error.localizedDescription);
      }
      
      [self completeOperation];
    }];
    
    [_dataTask resume];
}

@end
