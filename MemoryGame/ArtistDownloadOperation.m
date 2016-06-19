//
//  ArtistDownloadOperation.m
//  MemoryGame
//
//  
//  
//

#import "ArtistDownloadOperation.h"
#import "Constants.h"

@interface ArtistDownloadOperation ()
@end

@implementation ArtistDownloadOperation {
  NSURLSessionDataTask *_dataTask;
}

-(id)init {
  if (self = [super init])  {
    _artistId = @"";
  }
  return self;
}

- (void)main {
  NSString *urlString = [NSString stringWithFormat:@"http://api.soundcloud.com/users/%@?client_id=%@", _artistId, clientID];
  NSURL *url = [NSURL URLWithString:urlString];
  NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
  [request setHTTPMethod:@"GET"];
  _dataTask = [[NSURLSession sharedSession] dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
    
    if (!error){
      NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
      
      if (httpResp.statusCode == 200){
        NSError *jsonErr;
        
        NSDictionary *dataDictionary =
        [NSJSONSerialization JSONObjectWithData:data
                                        options:NSJSONReadingAllowFragments
                                          error:&jsonErr];
        
        if (!jsonErr){
          self.result = dataDictionary;
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
