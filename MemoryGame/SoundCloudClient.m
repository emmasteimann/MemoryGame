//
//  SoundCloudClient.m
//  MemoryGame
//
//  
//  
//

#import "SoundCloudClient.h"
#import "TrackDownloadOperation.h"
#import "ArtistDownloadOperation.h"
#import "ImageDownloader.h"
#import "Artist.h"
#import "Track.h"
#import "GameManager.h"

@interface SoundCloudClient ()
@property (nonatomic, strong) ImageDownloader *imageDownloader;
@end

@implementation SoundCloudClient {
  int _totalArtistImagesLoaded;
}

+ (instancetype)sharedInstance {
  static SoundCloudClient *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    self.imageDownloader = [[ImageDownloader alloc] init];
    self.artists = [NSMutableArray array];
    _userIdArray = @[@"18228471", @"65303942", @"2869822", @"1584240", @"4351913", @"1479884", @"568232", @"10064934"];
    _totalArtistImagesLoaded = 0;
  }
  return self;
}


- (NSArray *)loadArtistImages {
  for (NSString *artistId in _userIdArray) {
    ArtistDownloadOperation *artistDownloadOp = [[ArtistDownloadOperation alloc] init];
    artistDownloadOp.artistId = artistId;
    artistDownloadOp.completionHandler = ^(id result) {
      NSDictionary *artistInfo = (NSDictionary *)result;
      
      __block Artist *newArtist = [[Artist alloc] init];
      
      newArtist.artistId = artistId;
      
      dispatch_sync(dispatch_get_main_queue(), ^{
        NSMutableDictionary *artistComplication = [[[NSUserDefaults standardUserDefaults] objectForKey:@"artist-complication"] mutableCopy];
        if (artistComplication == nil) {
          artistComplication = [NSMutableDictionary dictionary];
          [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
          [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        if ([artistComplication objectForKey:newArtist.artistId] == nil) {
          DLog(@"Setting artist level ID: %@", newArtist.artistId);
          [artistComplication setObject:[NSNumber numberWithInt:5] forKey:newArtist.artistId];
          [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
          [[NSUserDefaults standardUserDefaults] synchronize];
        }
      });
      
      newArtist.name = artistInfo[@"username"];
      newArtist.artistInfo = artistInfo;
      [self.imageDownloader loadImageFromURLString:artistInfo[@"avatar_url"] callback:^(UIImage *image, NSString *url){
        [self addImage:image toArtist:newArtist];
      }];
      
    };
    
    [[NSOperationQueue mainQueue] addOperation: artistDownloadOp];
  }
  return @[];
}

- (void)addImage:(UIImage *)image toArtist:(Artist *)artist {
  artist.avatar = image;
  [_artists addObject:artist];
  _totalArtistImagesLoaded += 1;
  if (_totalArtistImagesLoaded == [_userIdArray count]) {
    [_delegate allArtistImagesLoaded];
  }
}

- (void)loadTrackImagesForArtist:(Artist *)artist {
  TrackDownloadOperation *trackDownloadOp = [[TrackDownloadOperation alloc] init];
  trackDownloadOp.artistId = artist.artistId;
  trackDownloadOp.completionHandler = ^(id result) {
    NSArray *tracks = (NSArray *)[result subarrayWithRange:(NSRange){0,5}];
    __block NSUInteger itemCount = [tracks count];
    __block NSMutableDictionary *tracksWon = [[[NSUserDefaults standardUserDefaults] objectForKey:@"tracks-won"] mutableCopy];
    for (NSDictionary *trackInfo in tracks) {
      dispatch_sync(dispatch_get_main_queue(), ^{
        if (tracksWon == nil) {
          tracksWon = [NSMutableDictionary dictionary];
          [[NSUserDefaults standardUserDefaults] setObject:tracksWon forKey:@"tracks-won"];
          [[NSUserDefaults standardUserDefaults] synchronize];
        }
      });


      if ([tracksWon objectForKey:[NSString stringWithFormat:@"%@", trackInfo[@"id"]]] == nil) {
        DLog(@"%@", trackInfo[@"id"]);
        __block Track *newTrack = [[Track alloc] init];
        
        newTrack.trackId = trackInfo[@"id"];
        newTrack.title = trackInfo[@"title"];
        newTrack.stream_url = trackInfo[@"stream_url"];
        newTrack.trackInfo = trackInfo;
        newTrack.image_url = trackInfo[@"artwork_url"];
        
        [self.imageDownloader loadImageFromURLString:trackInfo[@"artwork_url"] callback:^(UIImage *image, NSString *url){
          newTrack.image = image;
          [artist.tracks addObject:newTrack];
          [GameManager sharedInstance].trackState[newTrack.trackId] = newTrack.trackId;
          itemCount -= 1;
          if (itemCount < 1) {
            dispatch_async(dispatch_get_main_queue(), ^{
              [_delegate artistTracksLoaded:artist];
            });
          }
        }];
      } else {
        DLog(@"Skipping: %@", trackInfo[@"title"]);
        itemCount -= 1;
        if (itemCount < 1) {
          [_delegate artistTracksLoaded:artist];
        }
      }
      
    }
  };
  
  [[NSOperationQueue mainQueue] addOperation: trackDownloadOp];
}

@end
