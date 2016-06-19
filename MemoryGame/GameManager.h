//
//  GameManager.h
//  MemoryGame
//
//  
//  
//

#import <Foundation/Foundation.h>
#import "Artist.h"
#import "Track.h"

typedef NS_ENUM (NSInteger, GameState) {
  ImagesReady,
  HasSelectedFirstArtist,
  WaitingForGuess
};

@interface GameManager : NSObject


@property (assign, nonatomic) GameState gameState;
@property (assign, nonatomic) BOOL waitingForTrackDownloadToFinish;
@property (assign, nonatomic) int gridSize;
@property (strong, nonatomic) NSMutableDictionary *trackState;

+ (instancetype)sharedInstance;
- (int)getArtistComplication:(Artist *)artist;
- (void)resetArtistLevel:(Artist *)artist andTrack:(Track *)track;
- (void)increaseArtistComplication:(Artist *)artist;
- (void)addToTracksWon:(Track *)track withArtist:(Artist *)artist;
@end
