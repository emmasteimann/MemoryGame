//
//  MemoryGameTests.m
//  MemoryGameTests
//
//  
//  
//

#import <XCTest/XCTest.h>
#import "EarnedHeartsNode.h"
#import "HeartNode.h"
#import "GameManager.h"
#import "Artist.h"
#import "Track.h"

@interface MemoryGameTests : XCTestCase

@end

@implementation MemoryGameTests

- (void)setUp {
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    [super setUp];
}

- (void)tearDown {
    NSString *domainName = [[NSBundle mainBundle] bundleIdentifier];
    [[NSUserDefaults standardUserDefaults] removePersistentDomainForName:domainName];
    [super tearDown];
}

- (void)testEarnedHeartsDefault {
  EarnedHeartsNode *earnedNode = [[EarnedHeartsNode alloc] init];
  NSUInteger childCount = [earnedNode.children count];
  
  XCTAssertTrue(childCount == 3, @"Earned Hearts Node should have 3 children");
}

- (void)testEarnedHeartsStartsInactive {
  EarnedHeartsNode *earnedNode = [[EarnedHeartsNode alloc] init];
  int heartsActive = 0;
  
  for (HeartNode *node in earnedNode.children) {
    if (node.isActiveHeart) {
      heartsActive += 1;
    }
  }
  
  XCTAssertTrue(heartsActive == 0, @"It should have no active hearts.");
}

- (void)testSetActiveHeart {
  EarnedHeartsNode *earnedNode = [[EarnedHeartsNode alloc] init];
  [earnedNode setActiveHeart:1];
  
  int heartsActive = 0;
  
  for (HeartNode *node in earnedNode.children) {
    if (node.isActiveHeart) {
      heartsActive += 1;
    }
  }
  
  XCTAssertTrue(heartsActive == 1, @"setActiveHeart: should increment hearts.");
}

- (void)testGetArtistComplication {
  Artist *complicatedArtist = [self getComplicatedArtist];
  int artistLevel = [[GameManager sharedInstance] getArtistComplication:complicatedArtist];
  XCTAssertTrue(artistLevel == 5, @"Artist starts with complications (5).");
}

- (void)testGetArtistComplicationIncrease {
  Artist *complicatedArtist = [self getComplicatedArtist];
  [[GameManager sharedInstance] increaseArtistComplication:complicatedArtist];
  int artistLevel = [[GameManager sharedInstance] getArtistComplication:complicatedArtist];
  XCTAssertTrue(artistLevel == 6, @"Artist can get more complicated (6).");
}

- (void)testGetArtistComplicationReset {
  Artist *complicatedArtist = [self getComplicatedArtist];
  [[GameManager sharedInstance] increaseArtistComplication:complicatedArtist];
  [[GameManager sharedInstance] resetArtistLevel:complicatedArtist andTrack:[self mockTrack]];
  int artistLevel = [[GameManager sharedInstance] getArtistComplication:complicatedArtist];
  XCTAssertTrue(artistLevel == 5, @"Artist can get less complicated (5).");
}

- (void)testTrackWinning {
  NSMutableDictionary *tracksWon = [[NSUserDefaults standardUserDefaults] objectForKey:@"tracks-won"];
  
  XCTAssertTrue(tracksWon == nil, @"Tracks won are nil to start.");

  tracksWon = [NSMutableDictionary dictionary];
  [[NSUserDefaults standardUserDefaults] setObject:tracksWon forKey:@"tracks-won"];
  [[NSUserDefaults standardUserDefaults] synchronize];
  
  Track *mockTrack = [self mockTrack];
  Artist *mockArtist = [self mockArtist];
  
  mockArtist.tracks = [NSMutableArray array];
  [mockArtist.tracks addObject:mockTrack];
  
  [[GameManager sharedInstance] addToTracksWon:mockTrack withArtist:mockArtist];
  
  tracksWon = [[NSUserDefaults standardUserDefaults] objectForKey:@"tracks-won"];
  
  XCTAssertTrue(tracksWon[mockTrack.trackId] != nil, @"Tracks won populate correctly.");
  XCTAssertTrue([mockArtist.tracks count] == 0, @"Artist tracks are emptied");
}

- (Artist *)getComplicatedArtist {
  Artist *mockArtist = [self mockArtist];
  NSMutableDictionary *artistComplication = [[[NSUserDefaults standardUserDefaults] objectForKey:@"artist-complication"] mutableCopy];
  if (artistComplication == nil) {
    artistComplication = [NSMutableDictionary dictionary];
    [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  
  if ([artistComplication objectForKey:mockArtist.artistId] == nil) {
    [artistComplication setObject:[NSNumber numberWithInt:5] forKey:mockArtist.artistId];
    [[NSUserDefaults standardUserDefaults] setObject:artistComplication forKey:@"artist-complication"];
    [[NSUserDefaults standardUserDefaults] synchronize];
  }
  return mockArtist;
}

- (Artist *)mockArtist {
  Artist *newArtist = [[Artist alloc] init];
  newArtist.artistId = @"1";
  newArtist.name = @"Prince";
  newArtist.avatar = [UIImage imageNamed:@"duck"];
  return newArtist;
}

- (Track *)mockTrack {
  Track *newTrack = [[Track alloc] init];
  newTrack.trackId = @"1";
  newTrack.title = @"Raspberry Beret";
  newTrack.image = [UIImage imageNamed:@"duck"];
  newTrack.stream_url = @"https://api.soundcloud.com/tracks/238838283/stream";
  newTrack.image_url = @"https://i1.sndcdn.com/artworks-000140591467-h05mh6-large.jpg";
  return newTrack;
}

@end
