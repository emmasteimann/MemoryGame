//
//  GameManager.m
//  MemoryGame
//
//  
//  
//

#import "GameManager.h"

@implementation GameManager

+ (instancetype)sharedInstance {
  static GameManager *sharedInstance = nil;
  static dispatch_once_t onceToken;
  
  dispatch_once(&onceToken, ^{
    sharedInstance = [[self alloc] init];
  });
  
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    _gameState = 0;
    _gridSize = 5;
    _trackState = [NSMutableDictionary dictionary];
    _waitingForTrackDownloadToFinish = NO;
  }
  return self;
}

-(void)track:(Track *)track hasHearts:(int)hearts {
  _trackState[track.trackId] = [NSNumber numberWithInt:hearts];
}


- (int)getArtistComplication:(Artist *)artist {
  NSMutableDictionary *artistComplication = [[[NSUserDefaults standardUserDefaults] objectForKey:@"artist-complication"] mutableCopy];
  
  return [artistComplication[artist.artistId] intValue];
}

- (void)resetArtistLevel:(Artist *)artist andTrack:(Track *)track  {
  NSMutableDictionary *artistComplication = [[[NSUserDefaults standardUserDefaults] objectForKey:@"artist-complication"] mutableCopy];
  int artistLevel = [artistComplication[artist.artistId] intValue];
  
  int levelReset = (3 * floor((artistLevel - 5)/3)) + 5;
  artistComplication[artist.artistId] = [NSNumber numberWithInt:levelReset];
  
  [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [[NSUserDefaults standardUserDefaults] setObject:nil forKey:[NSString stringWithFormat:@"%@", track.trackId]];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)increaseArtistComplication:(Artist *)artist {
  NSMutableDictionary *artistComplication = [[[NSUserDefaults standardUserDefaults] objectForKey:@"artist-complication"] mutableCopy];
  int artistLevel = [artistComplication[artist.artistId] intValue];
  artistLevel += 1;
  
  if (artistLevel > _gridSize * 2) {
    artistLevel = _gridSize * 2;
  }
  
  artistComplication[artist.artistId] = [NSNumber numberWithInt:artistLevel];
  
  [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

-(void)addToTracksWon:(Track *)track withArtist:(Artist *)artist {
  NSMutableDictionary *tracksWon = [[[NSUserDefaults standardUserDefaults]  objectForKey:@"tracks-won"] mutableCopy];
  
  NSString *trackId = [NSString stringWithFormat:@"%@", track.trackId];
  tracksWon[trackId] = [NSMutableDictionary dictionary];
  
  
  tracksWon[trackId] = @{@"image_url": track.image_url, @"stream_url": track.stream_url};
  
  [[NSUserDefaults standardUserDefaults] setObject:[tracksWon copy] forKey:@"tracks-won"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  [artist.tracks removeObject:track];
}

@end
